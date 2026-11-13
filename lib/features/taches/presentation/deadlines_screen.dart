import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow_app/features/taches/application/taches_provider.dart';
import 'package:campusflow_app/core/theme.dart';
import 'package:campusflow_app/core/dates.dart';
import 'package:campusflow_app/features/taches/presentation/task_card.dart';
import 'package:campusflow_app/features/taches/presentation/task_detail_screen.dart';

/// Wireframe « Échéances » : la semaine en premier, filtres À faire / En retard /
/// Terminées, bouton « + Nouvelle tâche ».
/// Si la zone de contenu fait au moins 840 dp, la liste et le détail sont côte
/// à côte. LayoutBuilder mesure la place donnée par le parent (l'écran moins le
/// rail de navigation), pas l'écran entier comme MediaQuery.
class DeadlinesScreen extends ConsumerStatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  ConsumerState<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends ConsumerState<DeadlinesScreen> {
  // État éphémère (une seule vue l'utilise) : setState suffit, pas besoin de Riverpod.
  String? _selection; // tâche affichée à droite en mode étendu

  @override
  Widget build(BuildContext context) {
    // watch dans build : l'écran se reconstruit quand la liste change.
    final etat = ref.watch(tachesProvider);
    final aFaire = ref.watch(tachesFiltreesProvider(Filtre.aFaire));
    final enRetard = ref.watch(tachesFiltreesProvider(Filtre.enRetard));
    final faites = ref.watch(tachesFiltreesProvider(Filtre.faites));

    Widget contenu(BuildContext context, BoxConstraints contraintes) {
      final etendu = contraintes.maxWidth >= Tokens.etendu;

      void ouvrir(Task t) {
        if (etendu) {
          setState(() => _selection = t.id);
        } else {
          context.go('/taches/${t.id}'); // l'adresse s'affiche dans le navigateur
        }
      }

      final listes = TabBarView(
        children: [
          _ListeAFaire(taches: aFaire, ouvrir: ouvrir, selection: _selection),
          _ListeSimple(
            taches: enRetard,
            ouvrir: ouvrir,
            selection: _selection,
            vide: 'Aucun retard. Bravo !',
          ),
          _ListeSimple(
            taches: faites,
            ouvrir: ouvrir,
            selection: _selection,
            vide: 'Aucune tâche terminée pour l’instant.',
          ),
        ],
      );

      if (!etendu) return listes;

      final selection = _selection;
      return Row(
        children: [
          Expanded(flex: 2, child: listes),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: selection != null && ref.watch(tacheParIdProvider(selection)) != null
                ? TaskDetailView(
                    key: ValueKey(selection),
                    taskId: selection,
                    apresSuppression: () => setState(() => _selection = null),
                  )
                : const _AucuneSelection(),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Échéances'),
          actions: [
            IconButton(
              tooltip: 'Actualiser',
              icon: const Icon(Icons.refresh),
              onPressed: etat.isLoading ? null : () => ref.read(tachesProvider.notifier).recharger(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'À faire (${aFaire.length})'),
              Tab(text: 'En retard (${enRetard.length})'),
              Tab(text: 'Terminées (${faites.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/taches/nouvelle'),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle tâche'),
        ),
        // AsyncValue : les trois états, tous traités.
        body: etat.when(
          loading: () => const Center(child: CircularProgressIndicator(semanticsLabel: 'Chargement')),
          error: (_, _) => _Erreur(
            message: 'Impossible de charger les échéances. Vérifie ta connexion.',
            reessayer: () => ref.read(tachesProvider.notifier).recharger(),
          ),
          data: (_) => LayoutBuilder(builder: contenu),
        ),
      ),
    );
  }
}

/// À faire, regroupé : En retard · Cette semaine · Plus tard.
class _ListeAFaire extends StatelessWidget {
  const _ListeAFaire({required this.taches, required this.ouvrir, this.selection});

  final List<Task> taches;
  final void Function(Task) ouvrir;
  final String? selection;

  @override
  Widget build(BuildContext context) {
    if (taches.isEmpty) {
      return const _Vide(texte: 'Rien à rendre. Profite !');
    }
    final enRetard = taches.where((t) => t.enRetard).toList();
    final semaine = taches
        .where((t) => !t.enRetard && ecartEnJours(t.echeance) < 7)
        .toList();
    final plusTard = taches
        .where((t) => !t.enRetard && ecartEnJours(t.echeance) >= 7)
        .toList();

    // Une seule liste à plat : un en-tête, puis ses tâches, groupe après groupe.
    final elements = <Object>[
      for (final (titre, groupe) in [
        ('En retard', enRetard),
        ('Cette semaine', semaine),
        ('Plus tard', plusTard),
      ])
        if (groupe.isNotEmpty) ...[
          (titre: titre, nombre: groupe.length),
          ...groupe,
        ],
    ];

    // ListView.builder ne construit que les lignes visibles (séance 5).
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96), // place pour le bouton flottant
      itemCount: elements.length,
      itemBuilder: (context, i) => switch (elements[i]) {
        final Task t => TaskCard(task: t, onTap: () => ouvrir(t), selectionnee: t.id == selection),
        (:final String titre, :final int nombre) =>
          _EnTete(titre: titre, nombre: nombre, alerte: titre == 'En retard'),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _ListeSimple extends StatelessWidget {
  const _ListeSimple({required this.taches, required this.ouvrir, required this.vide, this.selection});

  final List<Task> taches;
  final void Function(Task) ouvrir;
  final String vide;
  final String? selection;

  @override
  Widget build(BuildContext context) {
    if (taches.isEmpty) return _Vide(texte: vide);
    return ListView.builder(
      padding: const EdgeInsets.only(top: Tokens.s, bottom: 96),
      itemCount: taches.length,
      itemBuilder: (context, i) {
        final t = taches[i];
        return TaskCard(task: t, onTap: () => ouvrir(t), selectionnee: t.id == selection);
      },
    );
  }
}

class _EnTete extends StatelessWidget {
  const _EnTete({required this.titre, required this.nombre, this.alerte = false});

  final String titre;
  final int nombre;
  final bool alerte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Tokens.m, Tokens.m, Tokens.m, Tokens.s),
        child: Text(
          '$titre · $nombre',
          style: theme.textTheme.titleSmall?.copyWith(
            color: alerte ? theme.colorScheme.error : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Vide extends StatelessWidget {
  const _Vide({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: Tokens.m),
            Text(texte, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _Erreur extends StatelessWidget {
  const _Erreur({required this.message, required this.reessayer});

  final String message;
  final VoidCallback reessayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: Tokens.m),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: Tokens.m),
            FilledButton.icon(
              onPressed: reessayer,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AucuneSelection extends StatelessWidget {
  const _AucuneSelection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Sélectionne une tâche pour voir son détail.',
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
