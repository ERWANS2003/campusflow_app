import 'package:flutter/material.dart';

import '../state/campus_store.dart';
import '../theme.dart';

/// Plan : Profil → compte, préférences, déconnexion.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);
    final user = store.utilisateur;
    final theme = Theme.of(context);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Tokens.m),
        children: [
          // Compte
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                user.nom[0],
                style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: Tokens.m),
          Text(user.nom, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          Text(
            user.niveau,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: Tokens.l),
          const _Section('Compte'),
          ListTile(leading: const Icon(Icons.mail_outline), title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('Progression'),
            subtitle: Text('${store.terminees.length} tâche(s) faite(s) sur ${store.taches.length}'),
          ),
          const _Section('Préférences'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Rappels avant échéance'),
            value: store.rappelsActives,
            onChanged: store.changerRappels,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Thème sombre'),
            value: store.themeSombre,
            onChanged: store.changerTheme,
          ),
          const Divider(height: Tokens.l * 2),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('Se déconnecter', style: TextStyle(color: theme.colorScheme.error)),
            onTap: store.deconnecter,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Tokens.m, Tokens.m, Tokens.m, Tokens.s),
        child: Text(
          titre,
          style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
