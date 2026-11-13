import 'package:campusflow_models/campusflow_models.dart' show Task;

/// Le contrat : ce que l'application peut demander sur les tâches.
/// Il ne dit pas COMMENT : l'API (ApiTaskRepository) ou la mémoire
/// (FakeTaskRepository, pour les tests) le font chacune à leur façon.
abstract interface class TaskRepository {
  /// GET /taches
  Future<List<Task>> lister();

  /// POST /taches → 201 + la tâche créée
  Future<Task> ajouter(Task tache);

  /// PATCH /taches/:id avec tous les champs (formulaire de modification)
  Future<Task> modifier(Task tache);

  /// PATCH /taches/:id avec {"terminee": …} (cocher, décocher)
  Future<Task> basculer(String id, {required bool terminee});

  /// DELETE /taches/:id
  Future<void> supprimer(String id);
}
