import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/features/auth/application/session_provider.dart';
import 'package:campusflow_app/core/theme.dart';

/// Wireframe « Connexion » : logo CampusFlow, Email, Mot de passe, Se connecter.
/// Après connexion, le routeur redirige seul vers /taches.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _masque = true; // état éphémère : setState suffit

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  void _seConnecter() {
    if (!_form.currentState!.validate()) return;
    ref.read(sessionProvider.notifier).connecter(_email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Tokens.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo CampusFlow, image déclarée dans pubspec.yaml (assets)
                    Image.asset(
                      'assets/images/logo.png',
                      height: 88,
                      semanticLabel: 'Logo CampusFlow',
                    ),
                    const SizedBox(height: Tokens.m),
                    Text(
                      'CampusFlow',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Ne rate plus aucun rendu.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: Tokens.l * 1.5),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'amina@etudiant.bf',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Saisis une adresse email valide.' : null,
                    ),
                    const SizedBox(height: Tokens.m),
                    TextFormField(
                      controller: _motDePasse,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _masque ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
                          icon: Icon(_masque ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _masque = !_masque),
                        ),
                      ),
                      obscureText: _masque,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _seConnecter(),
                      validator: (v) =>
                          (v == null || v.length < 4) ? 'Au moins 4 caractères.' : null,
                    ),
                    const SizedBox(height: Tokens.l),
                    FilledButton(onPressed: _seConnecter, child: const Text('Se connecter')),
                    const SizedBox(height: Tokens.m),
                    Text(
                      'Démo : n’importe quel email et un mot de passe de 4 caractères.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
