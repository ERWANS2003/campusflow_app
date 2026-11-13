import 'package:flutter/material.dart';

import 'package:campusflow_app/core/theme.dart';

/// Route /demarrage : affichée le temps de vérifier le jeton enregistré
/// (GET /me). Le routeur part ensuite vers /taches ou /login.
class DemarrageScreen extends StatelessWidget {
  const DemarrageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 88, semanticLabel: 'Logo CampusFlow'),
            const SizedBox(height: Tokens.l),
            const CircularProgressIndicator(semanticsLabel: 'Connexion en cours'),
          ],
        ),
      ),
    );
  }
}
