import 'package:campusflow_app/app.dart';
import 'package:campusflow_app/core/dates.dart';
import 'package:campusflow_app/core/router.dart';
import 'package:campusflow_app/core/token_storage.dart';
import 'package:campusflow_app/features/auth/application/session_provider.dart';
import 'package:campusflow_app/features/auth/data/auth_repository.dart';
import 'package:campusflow_app/features/cours/application/cours_provider.dart';
import 'package:campusflow_app/features/cours/data/cours_repository.dart';
import 'package:campusflow_app/features/taches/application/taches_provider.dart';
import 'package:campusflow_app/features/taches/data/fake_task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Les dépôts en mémoire, injectés par Riverpod : aucun serveur nécessaire.
List<Override> _sansReseau({bool echec = false, FakeTaskRepository? depot, TokenStorage? stockage}) => [
      taskRepositoryProvider.overrideWithValue(depot ?? FakeTaskRepository(echec: echec)),
      coursRepositoryProvider.overrideWithValue(const FakeCoursRepository()),
      authRepositoryProvider.overrideWithValue(const FakeAuthRepository()),
      tokenStorageProvider.overrideWithValue(stockage ?? MemoireTokenStorage()),
    ];

Widget _app({bool echec = false}) => ProviderScope(
      retry: (_, _) => null,
      overrides: _sansReseau(echec: echec),
      child: const CampusFlowApp(),
    );

ProviderContainer _conteneur(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(CampusFlowApp)));

String _adresse(WidgetTester tester) =>
    _conteneur(tester).read(routerProvider).routerDelegate.currentConfiguration.uri.toString();

Future<void> _seConnecter(WidgetTester tester, {String motDePasse = 'secret'}) async {
  await tester.pumpAndSettle(); // /demarrage → /login
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'amina@etudiant.bf');
  await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), motDePasse);
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
}

Future<void> _connecter(ProviderContainer c) async {
  await c.read(sessionProvider.future); // la session a fini de lire le stockage
  await c.read(sessionProvider.notifier).connecter('amina@etudiant.bf', 'secret');
}

void _telephone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 800); // téléphone du brief
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  group('connexion (séance 7)', () {
    testWidgets('mauvais mot de passe : message sous le formulaire, on reste sur /login', (tester) async {
      await tester.pumpWidget(_app());
      await _seConnecter(tester, motDePasse: 'mauvais'); // le faux serveur répond 401

      expect(find.text('Email ou mot de passe incorrect.'), findsOneWidget);
      expect(_adresse(tester), '/login');
      expect(await _conteneur(tester).read(tokenStorageProvider).lire(), isNull);
    });

    testWidgets('jeton déjà enregistré : connecté au démarrage, sans repasser par /login', (tester) async {
      final stockage = MemoireTokenStorage();
      await stockage.ecrire('jeton-test');
      await tester.pumpWidget(ProviderScope(
        retry: (_, _) => null,
        overrides: _sansReseau(stockage: stockage),
        child: const CampusFlowApp(),
      ));
      await tester.pumpAndSettle();

      expect(_adresse(tester), '/taches');
    });

    testWidgets('la déconnexion efface le jeton du stockage', (tester) async {
      _telephone(tester);
      await tester.pumpWidget(_app());
      await _seConnecter(tester);
      final stockage = _conteneur(tester).read(tokenStorageProvider);
      expect(await stockage.lire(), 'jeton-test');

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();

      expect(await stockage.lire(), isNull);
    });
  });

  group('navigation (go_router)', () {
    testWidgets('non connecté : redirigé vers /login', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(_adresse(tester), '/login');
      expect(find.bySemanticsLabel('Logo CampusFlow'), findsOneWidget); // asset
    });

    testWidgets('connexion → /taches, puis détail → /taches/t1', (tester) async {
      _telephone(tester);
      await tester.pumpWidget(_app());
      await _seConnecter(tester);

      expect(_adresse(tester), '/taches');
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.textContaining('Cette semaine'), findsOneWidget);

      await tester.tap(find.text('Rendu TP Dart'));
      await tester.pumpAndSettle();
      expect(_adresse(tester), '/taches/t1');
      expect(find.text('Marquer comme fait'), findsOneWidget);
    });

    testWidgets('déconnexion depuis Profil → /login', (tester) async {
      _telephone(tester);
      await tester.pumpWidget(_app());
      await _seConnecter(tester);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(_adresse(tester), '/profil');

      await tester.tap(find.text('Se déconnecter'));
      await tester.pumpAndSettle();
      expect(_adresse(tester), '/login');
    });
  });

  group('état partagé (Riverpod)', () {
    testWidgets('ajouter une tâche en 3 appuis, avec SnackBar', (tester) async {
      await tester.pumpWidget(_app());
      await _seConnecter(tester);

      await tester.tap(find.text('Nouvelle tâche')); // 1
      await tester.pumpAndSettle();
      expect(_adresse(tester), '/taches/nouvelle');
      await tester.enterText(find.widgetWithText(TextFormField, 'Titre'), 'Lire les HIG'); // 2
      await tester.tap(find.text('Enregistrer')); // 3
      await tester.pumpAndSettle();

      expect(find.text('Lire les HIG'), findsOneWidget);
      expect(find.text('Tâche « Lire les HIG » ajoutée'), findsOneWidget);
    });

    testWidgets('cocher dans le détail met à jour la liste et les filtres', (tester) async {
      _telephone(tester);
      await tester.pumpWidget(_app());
      await _seConnecter(tester);
      expect(find.text('Terminées (1)'), findsOneWidget);

      await tester.tap(find.text('Rendu TP Dart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marquer comme fait'));
      await tester.pumpAndSettle();
      expect(_conteneur(tester).read(tacheParIdProvider('t1'))!.terminee, isTrue);

      await tester.tap(find.byTooltip('Retour')); // bouton retour de l'AppBar
      await tester.pumpAndSettle();
      expect(_adresse(tester), '/taches');
      expect(find.text('Terminées (2)'), findsOneWidget); // même donnée, aucun paramètre
    });

    testWidgets('erreur réseau : message et bouton réessayer', (tester) async {
      await tester.pumpWidget(_app(echec: true));
      await _seConnecter(tester);

      expect(find.textContaining('Impossible de charger'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('tablette en paysage : rail, liste et détail côte à côte', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app());
      await _seConnecter(tester);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Sélectionne une tâche pour voir son détail.'), findsOneWidget);

      await tester.tap(find.text('Projet Flutter'));
      await tester.pumpAndSettle();
      expect(find.text('Marquer comme fait'), findsOneWidget);
      expect(_adresse(tester), '/taches'); // sélection locale, pas de navigation
    });
  });

  group('logique sans interface', () {
    late ProviderContainer conteneur;

    setUp(() {
      conteneur = ProviderContainer(
        retry: (_, _) => null,
        overrides: _sansReseau(),
      );
      addTearDown(conteneur.dispose);
    });

    test('rien n’est chargé tant qu’on n’est pas connecté', () async {
      expect(await conteneur.read(tachesProvider.future), isEmpty);
    });

    test('basculer remplace la liste (état immuable) et met à jour les filtres', () async {
      await _connecter(conteneur);
      final avant = await conteneur.read(tachesProvider.future);
      expect(conteneur.read(tachesFiltreesProvider(Filtre.enRetard)).map((t) => t.id), ['t4']);

      await conteneur.read(tachesProvider.notifier).basculer('t4');

      final apres = conteneur.read(tachesProvider).value!;
      expect(identical(avant, apres), isFalse); // nouvelle liste, pas de state.add
      expect(conteneur.read(tachesFiltreesProvider(Filtre.enRetard)), isEmpty);
      expect(conteneur.read(tachesFiltreesProvider(Filtre.faites)).map((t) => t.id), contains('t4'));
    });

    test('cocher échoue côté serveur : la case revient et l’erreur remonte', () async {
      final depot = FakeTaskRepository();
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: _sansReseau(depot: depot),
      );
      addTearDown(c.dispose);
      await _connecter(c);
      await c.read(tachesProvider.future);
      await depot.supprimer('t1'); // le serveur ne connaît plus t1 → 404

      await expectLater(c.read(tachesProvider.notifier).basculer('t1'), throwsA(isA<Object>()));
      expect(c.read(tacheParIdProvider('t1'))!.terminee, isFalse); // état d'avant remis
    });

    test('les cours viennent du dépôt', () async {
      await _connecter(conteneur);
      final cours = await conteneur.read(coursProvider.future);
      expect(cours.map((c) => c.id), ['mobile', 'ux', 'bdd']);
    });

    test('déconnexion : la liste est vidée', () async {
      await _connecter(conteneur);
      expect(await conteneur.read(tachesProvider.future), isNotEmpty);

      await conteneur.read(sessionProvider.notifier).deconnecter();
      expect(await conteneur.read(tachesProvider.future), isEmpty);
    });
  });

  test('dates en français', () {
    final lundi = DateTime(2026, 10, 26, 9);
    expect(jourRelatif(DateTime(2026, 10, 27), maintenant: lundi), 'demain');
    expect(jourRelatif(DateTime(2026, 10, 30), maintenant: lundi), 'ven.');
    expect(dateLongue(DateTime(2026, 10, 30, 17)), 'vendredi 30 oct. à 17 h');
    expect(libelleRappel(const Duration(days: 1)), '1 jour avant');
  });
}
