import 'package:campusflow_models/campusflow_models.dart' show Course;
import 'package:dio/dio.dart';

import 'package:campusflow_app/core/api_exception.dart';

/// Contrat d'accès aux cours (lecture seule).
abstract interface class CoursRepository {
  /// GET /cours
  Future<List<Course>> lister();
}

class ApiCoursRepository implements CoursRepository {
  ApiCoursRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Course>> lister() async {
    try {
      final r = await _dio.get<List<dynamic>>('/cours');
      return [for (final j in r.data!) Course.fromJson(j as Map<String, dynamic>)];
    } on DioException catch (e) {
      throw ApiException.depuis(e);
    }
  }
}

/// Cours en mémoire, pour les tests.
class FakeCoursRepository implements CoursRepository {
  const FakeCoursRepository();

  @override
  Future<List<Course>> lister() async => const [
        Course(id: 'mobile', nom: 'Programmation mobile', enseignant: 'M. Compaoré'),
        Course(id: 'ux', nom: 'UX/UI mobile', enseignant: 'M. Compaoré'),
        Course(id: 'bdd', nom: 'Bases de données', enseignant: 'Mme Kaboré'),
      ];
}
