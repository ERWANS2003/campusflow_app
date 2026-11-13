import 'package:campusflow_models/campusflow_models.dart' show User;
import 'package:dio/dio.dart';

import 'package:campusflow_app/core/api_exception.dart';

/// Contrat de connexion.
abstract interface class AuthRepository {
  /// POST /login : renvoie le jeton et l'utilisateur, ou lève une ApiException 401.
  Future<(String jeton, User utilisateur)> connecter(String email, String motDePasse);

  /// GET /me : l'utilisateur du jeton enregistré (au redémarrage de l'appli).
  Future<User> moi();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<(String, User)> connecter(String email, String motDePasse) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>(
        '/login',
        data: {'email': email, 'motDePasse': motDePasse},
      );
      return (
        r.data!['jeton'] as String,
        User.fromJson(r.data!['utilisateur'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ApiException('Email ou mot de passe incorrect.', statut: 401);
      }
      throw ApiException.depuis(e);
    }
  }

  @override
  Future<User> moi() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/me');
      return User.fromJson(r.data!);
    } on DioException catch (e) {
      throw ApiException.depuis(e);
    }
  }
}

/// Connexion simulée pour les tests : tout mot de passe passe, sauf « mauvais ».
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository();

  static User _utilisateur(String email) {
    final prenom = email.split('@').first.split('.').first;
    return User(
      id: 'u1',
      nom: prenom.isEmpty ? 'Étudiant' : prenom[0].toUpperCase() + prenom.substring(1),
      email: email.contains('@') ? email : 'amina@etudiant.bf',
      niveau: 'Master 1 Informatique',
    );
  }

  @override
  Future<(String, User)> connecter(String email, String motDePasse) async {
    if (motDePasse == 'mauvais') {
      throw const ApiException('Email ou mot de passe incorrect.', statut: 401);
    }
    return ('jeton-test', _utilisateur(email));
  }

  @override
  Future<User> moi() async => _utilisateur('amina@etudiant.bf');
}
