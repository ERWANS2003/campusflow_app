import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/core/api_config.dart';
import 'package:campusflow_app/core/token_storage.dart';
import 'package:campusflow_app/features/auth/application/session_provider.dart';

/// Le client HTTP, configuré une seule fois pour toute l'application.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: adresseApi(),
    connectTimeout: const Duration(seconds: 5), // délai max avant d'abandonner
    receiveTimeout: const Duration(seconds: 10),
  ));
  dio.interceptors.add(AuthInterceptor(ref));
  ref.onDispose(dio.close);
  return dio;
});

/// Code exécuté autour de CHAQUE requête :
/// - avant : ajoute `Authorization: Bearer <jeton>` si on a un jeton ;
/// - après une erreur 401 : déconnecte, et le routeur renvoie vers /login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  // /login répond 401 pour un mauvais mot de passe, /me est géré par la session.
  static const _sansExpiration = {'/login', '/me'};

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final jeton = await _ref.read(tokenStorageProvider).lire();
    if (jeton != null) options.headers['Authorization'] = 'Bearer $jeton';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !_sansExpiration.contains(err.requestOptions.path)) {
      _ref.read(sessionProvider.notifier).expirer();
    }
    handler.next(err);
  }
}
