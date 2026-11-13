import 'package:campusflow_models/campusflow_models.dart' show Task;
import 'package:dio/dio.dart';

import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/features/taches/domain/task_repository.dart';

/// Implémentation qui parle au serveur REST avec Dio.
/// C'est le seul fichier des tâches qui connaît Dio et les adresses HTTP.
class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._dio);

  final Dio _dio;

  /// Exécute une requête et traduit les erreurs Dio en ApiException.
  Future<T> _appel<T>(Future<T> Function() requete) async {
    try {
      return await requete();
    } on DioException catch (e) {
      throw ApiException.depuis(e);
    }
  }

  Task _tache(Response<dynamic> r) => Task.fromJson(r.data as Map<String, dynamic>);

  @override
  Future<List<Task>> lister() => _appel(() async {
        final r = await _dio.get<List<dynamic>>('/taches');
        return [for (final j in r.data!) Task.fromJson(j as Map<String, dynamic>)];
      });

  @override
  Future<Task> ajouter(Task tache) =>
      _appel(() async => _tache(await _dio.post('/taches', data: tache.toJson())));

  @override
  Future<Task> modifier(Task tache) =>
      _appel(() async => _tache(await _dio.patch('/taches/${tache.id}', data: tache.toJson())));

  @override
  Future<Task> basculer(String id, {required bool terminee}) =>
      _appel(() async => _tache(await _dio.patch('/taches/$id', data: {'terminee': terminee})));

  @override
  Future<void> supprimer(String id) => _appel(() => _dio.delete('/taches/$id'));
}
