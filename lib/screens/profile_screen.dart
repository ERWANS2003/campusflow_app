import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/preferences_provider.dart';
import '../providers/session_provider.dart';
import '../providers/taches_provider.dart';
import '../theme.dart';

/// Route /profil : compte, préférences, déconnexion.
/// Se déconnecter suffit : le routeur redirige seul vers /login.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final prefs = ref.watch(preferencesProvider);
    final total = ref.watch(tachesProvider).value?.length ?? 0;
    final faites = ref.watch(tachesFiltreesProvider(Filtre.faites)).length;
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
            subtitle: Text('$faites tâche(s) faite(s) sur $total'),
          ),
          const _Section('Préférences'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Rappels avant échéance'),
            value: prefs.rappels,
            onChanged: ref.read(preferencesProvider.notifier).changerRappels,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Thème sombre'),
            value: prefs.themeSombre,
            onChanged: ref.read(preferencesProvider.notifier).changerTheme,
          ),
          const Divider(height: Tokens.l * 2),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('Se déconnecter', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => ref.read(sessionProvider.notifier).deconnecter(),
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
