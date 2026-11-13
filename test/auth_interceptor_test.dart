import 'package:campusflow_app/core/dio_provider.dart';
import 'package:campusflow_app/core/token_storage.dart';
import 'package:campusflow_app/features/auth/application/session_provider.dart';
import 'package:campusflow_app/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'faux_reseau.dart';

/// Vérifie l'intercepteur de dioProvider avec le vrai client Dio de l'appli,
/// branché sur un faux réseau.
void main() {
  late ProviderContainer conteneur;
  late MemoireTokenStorage stockage;

  setUp(() async {
    stockage = MemoireTokenStorage();
    conteneur = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        tokenStorageProvider.overrideWithValue(stockage),
        authRepositoryProvider.overrideWithValue(const FakeAuthRepository()),
      ],
    );
    addTearDown(conteneur.dispose);
    await conteneur.read(sessionProvider.future);
    await conteneur.read(sessionProvider.notifier).connecter('amina@etudiant.bf', 'secret');
  });

  test('chaque requête porte le jeton : Authorization: Bearer <jeton>', () async {
    final reseau = FauxReseau((_) => (200, []));
    conteneur.read(dioProvider).httpClientAdapter = reseau;

    await conteneur.read(dioProvider).get('/taches');

    expect(reseau.requetes.single.headers['Authorization'], 'Bearer jeton-test');
  });

  test('réponse 401 : jeton effacé et utilisateur déconnecté (→ /login)', () async {
    conteneur.read(dioProvider).httpClientAdapter = FauxReseau((_) => (401, {'message': 'expiré'}));

    await expectLater(conteneur.read(dioProvider).get('/taches'), throwsA(isA<DioException>()));
    await Future<void>.delayed(Duration.zero); // laisse la déconnexion se terminer

    expect(conteneur.read(sessionProvider).value, isNull);
    expect(await stockage.lire(), isNull);
  });

  test('401 sur /login (mauvais mot de passe) ne déconnecte pas la session en cours', () async {
    conteneur.read(dioProvider).httpClientAdapter = FauxReseau((_) => (401, {}));

    await expectLater(conteneur.read(dioProvider).post('/login'), throwsA(isA<DioException>()));
    await Future<void>.delayed(Duration.zero);

    expect(conteneur.read(sessionProvider).value, isNotNull);
  });
}
