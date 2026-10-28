import 'package:flutter/material.dart';

import '../theme.dart';
import 'courses_screen.dart';
import 'deadlines_screen.dart';
import 'profile_screen.dart';

/// Navigation principale : 3 destinations de même niveau.
/// - compact (< 600 dp) : barre de navigation inférieure, atteignable au pouce ;
/// - moyen et étendu (≥ 600 dp) : rail de navigation à gauche.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [DeadlinesScreen(), CoursesScreen(), ProfileScreen()];

  static const _destinations = [
    (icone: Icons.event_note_outlined, active: Icons.event_note, libelle: 'Échéances'),
    (icone: Icons.school_outlined, active: Icons.school, libelle: 'Cours'),
    (icone: Icons.person_outline, active: Icons.person, libelle: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final largeur = MediaQuery.sizeOf(context).width;

    if (largeur < Tokens.moyen) {
      return Scaffold(
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
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
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: Tokens.m),
              child: Icon(Icons.event_available, color: Theme.of(context).colorScheme.primary, size: 32),
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
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }
}
