import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/core/dio_provider.dart';
import 'package:campusflow_app/core/token_storage.dart';
import 'package:campusflow_app/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(dioProvider)),
);

/// Utilisateur connecté (null = déconnecté). Lu par le routeur, le profil,
/// et les tâches et cours qui ne se chargent qu'une fois connecté.
///
/// Flux : POST /login → jeton rangé dans le stockage chiffré → l'intercepteur
/// Dio l'ajoute à chaque requête → un 401 appelle [expirer] → retour à /login.
class SessionNotifier extends AsyncNotifier<User?> {
  TokenStorage get _stockage => ref.read(tokenStorageProvider);

  /// Au démarrage : un jeton déjà enregistré ? On demande au serveur à qui il appartient.
  @override
  Future<User?> build() async {
    final jeton = await _stockage.lire();
    if (jeton == null) return null;
    try {
      return await ref.read(authRepositoryProvider).moi();
    } on ApiException catch (e) {
      if (e.statut == 401) await _stockage.effacer(); // jeton expiré
      return null; // serveur injoignable ou jeton refusé : on repasse par /login
    }
  }

  /// Lève une ApiException (mauvais mot de passe, serveur coupé) que l'écran affiche.
  Future<void> connecter(String email, String motDePasse) async {
    final (jeton, utilisateur) = await ref.read(authRepositoryProvider).connecter(email, motDePasse);
    await _stockage.ecrire(jeton);
    state = AsyncData(utilisateur);
  }

  Future<void> deconnecter() async {
    await _stockage.effacer();
    state = const AsyncData(null);
  }

  /// Appelé par l'intercepteur quand le serveur répond 401 : le jeton ne vaut plus rien.
  Future<void> expirer() async {
    if (state.value == null) return;
    await deconnecter();
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, User?>(SessionNotifier.new);
