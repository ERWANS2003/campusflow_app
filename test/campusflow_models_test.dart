import 'package:campusflow_models/campusflow_models.dart';
import 'package:test/test.dart';

void main() {
  test('copyWith modifie un champ sans toucher à l\'original', () {
    final t = Task(
      id: 't1',
      titre: 'Rendu TP Dart',
      coursId: 'mobile',
      echeance: DateTime(2026, 10, 29),
    );

    final faite = t.copyWith(terminee: true);

    expect(faite.terminee, isTrue);
    expect(faite.titre, 'Rendu TP Dart');
    expect(t.terminee, isFalse); // l'original est inchangé
  });

  test('fromJson lit une tâche valide', () {
    final t = Task.fromJson({
      'id': 't2',
      'titre': 'Projet Flutter',
      'coursId': 'mobile',
      'echeance': '2026-10-30T17:00:00',
    });

    expect(t.titre, 'Projet Flutter');
    expect(t.echeance, DateTime(2026, 10, 30, 17));
    expect(t.description, isNull);
    expect(t.terminee, isFalse); // valeur par défaut
  });

  test('toJson puis fromJson redonne la même tâche (aller-retour)', () {
    final t = Task(
      id: 't9',
      titre: 'Lire les HIG',
      coursId: 'ux',
      echeance: DateTime(2026, 11, 20, 17),
      rappel: const Duration(days: 1),
    );

    final json = t.toJson();
    expect(json['echeance'], '2026-11-20T17:00:00.000');
    expect(json['rappelMinutes'], 1440);

    final relue = Task.fromJson(json);
    expect(relue.titre, t.titre);
    expect(relue.echeance, t.echeance);
    expect(relue.rappel, t.rappel);
    expect(relue.description, isNull);
  });

  test('erreurs attendues : JSON invalide et réseau coupé', () async {
    expect(
      () => Task.fromJson({'id': 't3', 'titre': 42}),
      throwsFormatException,
    );

    const repo = FakeTaskRepository(delai: Duration.zero, echec: true);
    await expectLater(repo.chargerTaches(), throwsException);
  });
}
