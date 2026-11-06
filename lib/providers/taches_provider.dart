import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';

/// Injection de dépendances : le dépôt est fourni par Riverpod.
/// Les tests le remplacent par un faux dépôt sans délai (overrideWithValue).
final taskRepositoryProvider = Provider<TaskRepository>((ref) => const FakeTaskRepository());

/// Liste des tâches, chargée de façon asynchrone.
/// AsyncValue donne les trois états d'un Future : chargement, erreur, donnée.
///
/// L'état est immuable : chaque action assigne une NOUVELLE liste à `state`,
/// jamais `state.add(...)` (l'écran ne se mettrait pas à jour).
class TachesNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // Se reconstruit à la connexion et à la déconnexion.
    final utilisateur = ref.watch(sessionProvider);
    if (utilisateur == null) return const [];
    final taches = await ref.watch(taskRepositoryProvider).chargerTaches();
    return _trier(taches);
  }

  List<Task> get _actuelles => state.value ?? const [];

  /// Ajoute la tâche, ou remplace celle qui a le même id.
  void enregistrer(Task tache) {
    final existe = _actuelles.any((t) => t.id == tache.id);
    state = AsyncData(_trier([
      for (final t in _actuelles) t.id == tache.id ? tache : t,
      if (!existe) tache,
    ]));
  }

  void basculer(String id) {
    state = AsyncData([
      for (final t in _actuelles) t.id == id ? t.copyWith(terminee: !t.terminee) : t,
    ]);
  }

  void supprimer(String id) {
    state = AsyncData([
      for (final t in _actuelles)
        if (t.id != id) t,
    ]);
  }

  Future<void> recharger() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => _trier(await ref.read(taskRepositoryProvider).chargerTaches()),
    );
  }

  static List<Task> _trier(List<Task> taches) =>
      [...taches]..sort((a, b) => a.echeance.compareTo(b.echeance));
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
