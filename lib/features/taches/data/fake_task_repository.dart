import 'package:campusflow_models/campusflow_models.dart' as modeles;
import 'package:campusflow_models/campusflow_models.dart' show Task;

import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/features/taches/domain/task_repository.dart';

/// Implémentation en mémoire, sans réseau : pour les tests et les démos hors ligne.
/// Mêmes méthodes que l'API, donc l'application ne voit pas la différence.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<Task>? initiales, this.echec = false}) : _taches = initiales;

  /// true : chaque appel échoue, comme un serveur coupé.
  final bool echec;
  List<Task>? _taches;

  Future<List<Task>> _donnees() async {
    if (echec) throw const ApiException('Pas de connexion au serveur.');
    // Par défaut : les données de démonstration du package de la séance 3.
    return _taches ??= await const modeles.FakeTaskRepository(delai: Duration.zero).chargerTaches();
  }

  Task _trouver(List<Task> taches, String id) => taches.firstWhere(
        (t) => t.id == id,
        orElse: () => throw const ApiException('Élément introuvable sur le serveur.', statut: 404),
      );

  @override
  Future<List<Task>> lister() async => [...await _donnees()];

  @override
  Future<Task> ajouter(Task tache) async {
    _taches = [...await _donnees(), tache];
    return tache;
  }

  @override
  Future<Task> modifier(Task tache) async {
    final taches = await _donnees();
    _trouver(taches, tache.id);
    _taches = [for (final t in taches) t.id == tache.id ? tache : t];
    return tache;
  }

  @override
  Future<Task> basculer(String id, {required bool terminee}) async {
    final modifiee = _trouver(await _donnees(), id).copyWith(terminee: terminee);
    return modifier(modifiee);
  }

  @override
  Future<void> supprimer(String id) async {
    final taches = await _donnees();
    _trouver(taches, id);
    _taches = [for (final t in taches) if (t.id != id) t];
  }
}
