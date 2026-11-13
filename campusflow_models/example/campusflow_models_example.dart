import 'package:campusflow_models/campusflow_models.dart';

Future<void> afficher(TaskRepository repo) async {
  print('Chargement…');
  try {
    final taches = await repo.chargerTaches();
    print('${taches.length} tâche(s) :');
    for (final t in taches) {
      print('  - $t');
    }
  } catch (e) {
    print('Erreur : $e');
  } finally {
    print('Fin du chargement\n');
  }
}

Future<void> main() async {
  await afficher(const FakeTaskRepository());
  await afficher(const FakeTaskRepository(echec: true));
}
