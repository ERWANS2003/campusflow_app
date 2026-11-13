import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Faux réseau pour Dio : note chaque requête et renvoie une réponse préparée.
/// On vérifie ainsi la méthode HTTP, l'adresse, les en-têtes et le corps envoyés,
/// sans serveur.
class FauxReseau implements HttpClientAdapter {
  FauxReseau(this.repondre);

  final (int, Object?) Function(RequestOptions options) repondre;
  final requetes = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requetes.add(options);
    final (statut, corps) = repondre(options);
    return ResponseBody.fromString(
      jsonEncode(corps),
      statut,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
