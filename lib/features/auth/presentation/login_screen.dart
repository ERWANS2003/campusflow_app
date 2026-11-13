import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/core/api_exception.dart';
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
  // États éphémères de cet écran : setState suffit.
  bool _masque = true;
  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  /// POST /login. Réussite : le jeton est rangé et le routeur part vers /taches.
  /// Échec (401, serveur coupé) : le message s'affiche sous le formulaire.
  Future<void> _seConnecter() async {
    if (_envoi || !_form.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      await ref.read(sessionProvider.notifier).connecter(_email.text.trim(), _motDePasse.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
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
                    if (_erreur != null) ...[
                      const SizedBox(height: Tokens.m),
                      Semantics(
                        liveRegion: true, // lu par le lecteur d'écran dès qu'il apparaît
                        child: Text(
                          _erreur!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: Tokens.l),
                    FilledButton(
                      onPressed: _envoi ? null : _seConnecter,
                      child: _envoi
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Se connecter'),
                    ),
                    const SizedBox(height: Tokens.m),
                    Text(
                      'Compte de démo (serveur server/) : amina@etudiant.bf / campus',
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
