import '../models/task.dart';

/// Le contrat : l'écran ne sait pas d'où viennent les tâches.
/// Plus tard, un ApiTaskRepository implémentera la même interface.
abstract interface class TaskRepository {
  Future<List<Task>> chargerTaches();
}

/// Dépôt simulé : renvoie du JSON en dur après un délai, comme un vrai serveur.
/// Les dates sont calculées à partir d'aujourd'hui pour que « cette semaine »
/// ait toujours du contenu.
class FakeTaskRepository implements TaskRepository {
  final Duration delai;
  final bool echec; // true pour simuler une coupure réseau

  const FakeTaskRepository({
    this.delai = const Duration(seconds: 1),
    this.echec = false,
  });

  static List<Map<String, dynamic>> _json(DateTime maintenant) {
    String dans(int jours, int heure, [int minute = 0]) => DateTime(
          maintenant.year,
          maintenant.month,
          maintenant.day + jours,
          heure,
          minute,
        ).toIso8601String();

    return [
      {
        'id': 't1',
        'titre': 'Rendu TP Dart',
        'coursId': 'mobile',
        'echeance': dans(1, 23, 59),
        'description': 'Package campusflow_models : 3 modèles, fromJson, 3 tests.',
        'rappelMinutes': 24 * 60,
      },
      {
        'id': 't2',
        'titre': 'Projet Flutter',
        'coursId': 'mobile',
        'echeance': dans(3, 17),
        'description': 'Maquette + 5 écrans du parcours principal.',
        'rappelMinutes': 24 * 60,
      },
      {
        'id': 't3',
        'titre': 'Examen UX',
        'coursId': 'ux',
        'echeance': dans(5, 8),
        'rappelMinutes': 2 * 24 * 60,
      },
      {
        'id': 't4',
        'titre': 'Fiche persona',
        'coursId': 'ux',
        'echeance': dans(-1, 18),
        'description': 'Persona fictif réaliste et deux job stories.',
      },
      {
        'id': 't5',
        'titre': 'TP SQL',
        'coursId': 'bdd',
        'echeance': dans(10, 12),
      },
      {
        'id': 't6',
        'titre': 'Dossier de conception v1',
        'coursId': 'mobile',
        'echeance': dans(-3, 23, 59),
        'terminee': true,
      },
    ];
  }

  @override
  Future<List<Task>> chargerTaches() async {
    await Future.delayed(delai);
    if (echec) {
      throw Exception('Réseau indisponible');
    }
    return _json(DateTime.now()).map(Task.fromJson).toList();
  }
}
