import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utilisateur connecté (null = déconnecté). État d'application : lu par le
/// routeur, le profil et la liste des tâches.
class SessionNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  /// Connexion simulée : pas de serveur pour l'instant (séance 7).
  void connecter(String email) {
    final prenom = email.split('@').first.split('.').first;
    state = User(
      id: 'u1',
      nom: prenom.isEmpty ? 'Étudiant' : prenom[0].toUpperCase() + prenom.substring(1),
      email: email,
      niveau: 'Master 1 Informatique',
    );
  }

  void deconnecter() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, User?>(SessionNotifier.new);
