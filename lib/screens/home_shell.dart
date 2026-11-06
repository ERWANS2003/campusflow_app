import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

/// Coquille de navigation du StatefulShellRoute : 3 destinations de même niveau.
/// - compact (< 600 dp) : barre de navigation inférieure, atteignable au pouce ;
/// - moyen et étendu (≥ 600 dp) : rail de navigation à gauche.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  /// Fourni par go_router : la branche active et la méthode goBranch.
  final StatefulNavigationShell shell;

  static const _destinations = [
    (icone: Icons.event_note_outlined, active: Icons.event_note, libelle: 'Échéances'),
    (icone: Icons.school_outlined, active: Icons.school, libelle: 'Cours'),
    (icone: Icons.person_outline, active: Icons.person, libelle: 'Profil'),
  ];

  // Retoucher l'onglet actif revient à sa racine (ex. Détail → Échéances).
  void _aller(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;

    if (largeur < Tokens.moyen) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _aller,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icone),
                selectedIcon: Icon(d.active),
                label: d.libelle,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _aller,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: Tokens.m),
              child: Image.asset('assets/images/logo.png', height: 36, semanticLabel: 'CampusFlow'),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icone),
                  selectedIcon: Icon(d.active),
                  label: Text(d.libelle),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: shell),
        ],
      ),
    );
  }
}
