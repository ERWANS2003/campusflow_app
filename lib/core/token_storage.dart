import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Où ranger le jeton d'authentification. Jamais en clair :
/// pas de shared_preferences pour un secret.
abstract interface class TokenStorage {
  Future<String?> lire();
  Future<void> ecrire(String jeton);
  Future<void> effacer();
}

/// Stockage chiffré : Keystore sur Android, Keychain sur iOS.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage();

  static const _cle = 'campusflow_jeton';
  static const _stockage = FlutterSecureStorage();

  @override
  Future<String?> lire() => _stockage.read(key: _cle);

  @override
  Future<void> ecrire(String jeton) => _stockage.write(key: _cle, value: jeton);

  @override
  Future<void> effacer() => _stockage.delete(key: _cle);
}

/// Stockage en mémoire, pour les tests (pas de Keystore dans un test).
class MemoireTokenStorage implements TokenStorage {
  String? _jeton;

  @override
  Future<String?> lire() async => _jeton;

  @override
  Future<void> ecrire(String jeton) async => _jeton = jeton;

  @override
  Future<void> effacer() async => _jeton = null;
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => const SecureTokenStorage());
