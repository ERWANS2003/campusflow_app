import 'package:dio/dio.dart';

/// Erreur d'API traduite pour l'utilisateur. Les écrans ne voient jamais
/// une DioException : ils ne savent pas que Dio existe.
class ApiException implements Exception {
  const ApiException(this.message, {this.statut});

  final String message;
  final int? statut; // code HTTP quand le serveur a répondu (401, 404, 500…)

  factory ApiException.depuis(DioException e) {
    final statut = e.response?.statusCode;
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        'Le serveur ne répond pas. Réessaie dans un instant.',
      DioExceptionType.connectionError => 'Pas de connexion au serveur.',
      _ => switch (statut) {
          401 => 'Session expirée : reconnecte-toi.',
          404 => 'Élément introuvable sur le serveur.',
          final s? when s >= 500 => 'Panne côté serveur ($s).',
          final s? => 'Requête refusée ($s).',
          null => 'Erreur réseau.',
        },
    };
    return ApiException(message, statut: statut);
  }

  @override
  String toString() => message;
}
