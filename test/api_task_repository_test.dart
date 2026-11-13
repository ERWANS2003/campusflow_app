import 'dart:convert';
import 'dart:typed_data';

import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/features/taches/data/api_task_repository.dart';
import 'package:campusflow_models/campusflow_models.dart' show Task;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux réseau pour Dio : note chaque requête et renvoie une réponse préparée.
/// On vérifie ainsi la méthode HTTP, l'adresse et le corps envoyés, sans serveur.
class _FauxReseau implements HttpClientAdapter {
  _FauxReseau(this.repondre);

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

const _json = {
  'id': 't1',
  'titre': 'Rendu TP Dart',
  'coursId': 'mobile',
  'echeance': '2026-11-16T23:59:00.000',
  'description': null,
  'rappelMinutes': 1440,
  'terminee': false,
};

(ApiTaskRepository, _FauxReseau) _depot((int, Object?) Function(RequestOptions) repondre) {
  final reseau = _FauxReseau(repondre);
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))..httpClientAdapter = reseau;
  return (ApiTaskRepository(dio), reseau);
}

void main() {
  test('lister : GET /taches et conversion JSON → Task', () async {
    final (depot, reseau) = _depot((_) => (200, [_json]));

    final taches = await depot.lister();

    expect(reseau.requetes.single.method, 'GET');
    expect(reseau.requetes.single.path, '/taches');
    expect(taches.single.titre, 'Rendu TP Dart');
    expect(taches.single.rappel, const Duration(days: 1));
  });

  test('cocher : PATCH /taches/t1 avec {"terminee": true}', () async {
    final (depot, reseau) = _depot((_) => (200, {..._json, 'terminee': true}));

    final tache = await depot.basculer('t1', terminee: true);

    final requete = reseau.requetes.single;
    expect(requete.method, 'PATCH');
    expect(requete.path, '/taches/t1');
    expect(requete.data, {'terminee': true});
    expect(tache.terminee, isTrue);
  });

  test('créer : POST /taches avec le JSON de la tâche', () async {
    final (depot, reseau) = _depot((o) => (201, o.data));
    final nouvelle = Task(
      id: 'x1',
      titre: 'Lire les HIG',
      coursId: 'ux',
      echeance: DateTime(2026, 11, 20, 17),
    );

    final creee = await depot.ajouter(nouvelle);

    expect(reseau.requetes.single.method, 'POST');
    expect((reseau.requetes.single.data as Map)['titre'], 'Lire les HIG');
    expect(creee.id, 'x1');
  });

  test('supprimer : DELETE /taches/t1', () async {
    final (depot, reseau) = _depot((_) => (200, {}));

    await depot.supprimer('t1');

    expect(reseau.requetes.single.method, 'DELETE');
    expect(reseau.requetes.single.path, '/taches/t1');
  });

  test('erreur 401 : traduite en ApiException lisible', () async {
    final (depot, _) = _depot((_) => (401, {'message': 'Jeton absent ou expiré.'}));

    await expectLater(
      depot.lister(),
      throwsA(isA<ApiException>()
          .having((e) => e.statut, 'statut', 401)
          .having((e) => e.message, 'message', contains('reconnecte'))),
    );
  });
}
