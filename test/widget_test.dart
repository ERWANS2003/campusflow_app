import 'package:campusflow_app/app.dart';
import 'package:campusflow_app/state/campus_store.dart';
import 'package:campusflow_app/utils/dates.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CampusStore _store({bool echec = false}) =>
    CampusStore(repository: FakeTaskRepository(delai: Duration.zero, echec: echec));

Future<void> _seConnecter(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'amina@etudiant.bf');
  await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), 'secret');
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('connexion puis liste des échéances de la semaine', (tester) async {
    tester.view.physicalSize = const Size(360, 800); // téléphone du brief
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(CampusFlowApp(store: _store()));

    await _seConnecter(tester);

    expect(find.text('Échéances'), findsWidgets);
    expect(find.textContaining('Cette semaine'), findsOneWidget);
    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget); // téléphone : barre inférieure
  });

  testWidgets('ajouter une tâche en 3 appuis', (tester) async {
    await tester.pumpWidget(CampusFlowApp(store: _store()));
    await _seConnecter(tester);

    await tester.tap(find.text('Nouvelle tâche')); // 1
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Titre'), 'Lire les HIG'); // 2
    await tester.tap(find.text('Enregistrer')); // 3
    await tester.pumpAndSettle();

    expect(find.text('Lire les HIG'), findsOneWidget);
  });

  testWidgets('marquer comme fait depuis le détail', (tester) async {
    final store = _store();
    await tester.pumpWidget(CampusFlowApp(store: store));
    await _seConnecter(tester);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();

    expect(store.tache('t1')!.terminee, isTrue);
    expect(find.text('Marquer à faire'), findsOneWidget);
  });

  testWidgets('erreur réseau : message et bouton réessayer', (tester) async {
    await tester.pumpWidget(CampusFlowApp(store: _store(echec: true)));
    await _seConnecter(tester);

    expect(find.textContaining('Impossible de charger'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('tablette en paysage : rail, liste et détail côte à côte', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(CampusFlowApp(store: _store()));
    await _seConnecter(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Sélectionne une tâche pour voir son détail.'), findsOneWidget);

    await tester.tap(find.text('Projet Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme fait'), findsOneWidget);
  });

  test('dates en français', () {
    final lundi = DateTime(2026, 10, 26, 9);
    expect(jourRelatif(DateTime(2026, 10, 27), maintenant: lundi), 'demain');
    expect(jourRelatif(DateTime(2026, 10, 30), maintenant: lundi), 'ven.');
    expect(dateLongue(DateTime(2026, 10, 30, 17)), 'vendredi 30 oct. à 17 h');
    expect(libelleRappel(const Duration(days: 1)), '1 jour avant');
  });
}
