import 'package:campusflow_models/campusflow_models.dart' show Task;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/core/dio_provider.dart';
import 'package:campusflow_app/features/auth/application/session_provider.dart';
import 'package:campusflow_app/features/taches/data/api_task_repository.dart';
import 'package:campusflow_app/features/taches/domain/regles.dart';
import 'package:campusflow_app/features/taches/domain/task_repository.dart';

/// Injection de dépendances : l'application parle à l'API.
/// Les tests remplacent ce fournisseur par un FakeTaskRepository (overrideWithValue).
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ApiTaskRepository(ref.watch(dioProvider)),
);

/// Liste des tâches, synchronisée avec le serveur.
/// AsyncValue donne les trois états à l'écran : chargement, erreur, donnée.
///
/// L'état reste immuable : chaque action assigne une NOUVELLE liste à `state`.
/// Une action réseau qui échoue lève une ApiException que l'écran affiche.
class TachesNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _depot => ref.read(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    // Se recharge à la connexion et se vide à la déconnexion.
    final utilisateur = ref.watch(sessionProvider);
    if (utilisateur == null) return const [];
    return trierParEcheance(await ref.watch(taskRepositoryProvider).lister());
  }

  List<Task> get _actuelles => state.value ?? const [];

  /// Remplace la tâche de même id, ou l'ajoute si elle n'existe pas.
  void _placer(Task tache) {
    final existe = _actuelles.any((t) => t.id == tache.id);
    state = AsyncData(trierParEcheance([
      for (final t in _actuelles) t.id == tache.id ? tache : t,
      if (!existe) tache,
    ]));
  }

  /// Création (POST) ou modification (PATCH) selon que la tâche existe déjà.
  /// On attend la réponse du serveur avant d'afficher : il fait foi.
  Future<void> enregistrer(Task tache) async {
    final existe = _actuelles.any((t) => t.id == tache.id);
    _placer(existe ? await _depot.modifier(tache) : await _depot.ajouter(tache));
  }

  /// Cocher : mise à jour optimiste (la case change tout de suite),
  /// puis PATCH. Si le serveur refuse, on remet l'ancienne liste.
  Future<void> basculer(String id) async {
    final avant = _actuelles;
    final tache = avant.firstWhere((t) => t.id == id);
    _placer(tache.copyWith(terminee: !tache.terminee));
    try {
      _placer(await _depot.basculer(id, terminee: !tache.terminee));
    } catch (_) {
      state = AsyncData(avant);
      rethrow;
    }
  }

  /// Suppression optimiste puis DELETE, annulée si le serveur refuse.
  Future<void> supprimer(String id) async {
    final avant = _actuelles;
    state = AsyncData([for (final t in avant) if (t.id != id) t]);
    try {
      await _depot.supprimer(id);
    } catch (_) {
      state = AsyncData(avant);
      rethrow;
    }
  }

  /// Bouton « Réessayer » et « Actualiser » : recharge depuis le serveur.
  Future<void> recharger() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => trierParEcheance(await _depot.lister()));
  }
}

final tachesProvider = AsyncNotifierProvider<TachesNotifier, List<Task>>(TachesNotifier.new);

/// Filtres de l'écran Échéances.
enum Filtre { aFaire, enRetard, faites }

/// Fournisseur dérivé : recalculé automatiquement quand la liste change.
final tachesFiltreesProvider = Provider.family<List<Task>, Filtre>((ref, filtre) {
  final taches = ref.watch(tachesProvider).value ?? const <Task>[];
  return switch (filtre) {
    Filtre.aFaire => [for (final t in taches) if (!t.terminee) t],
    Filtre.enRetard => [for (final t in taches) if (t.enRetard) t],
    Filtre.faites => [for (final t in taches.reversed) if (t.terminee) t],
  };
});

/// Une tâche par son id (null si introuvable), pour le détail et le formulaire.
final tacheParIdProvider = Provider.family<Task?, String>((ref, id) {
  final taches = ref.watch(tachesProvider).value ?? const <Task>[];
  for (final t in taches) {
    if (t.id == id) return t;
  }
  return null;
});
