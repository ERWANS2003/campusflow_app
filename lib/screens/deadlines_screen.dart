import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../state/campus_store.dart';
import '../theme.dart';
import '../utils/dates.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

/// Wireframe « Échéances » : la semaine en premier, onglets À faire / Terminées,
/// bouton « + Nouvelle tâche ».
/// Si la zone de contenu fait au moins 840 dp, la liste et le détail sont côte
/// à côte. LayoutBuilder mesure la place donnée par le parent (l'écran moins le
/// rail de navigation), pas l'écran entier comme MediaQuery.
class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  String? _selection; // tâche affichée à droite en mode étendu

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);

    Widget contenu(BuildContext context, BoxConstraints contraintes) {
      final etendu = contraintes.maxWidth >= Tokens.etendu;

      void ouvrir(Task t) {
        if (etendu) {
          setState(() => _selection = t.id);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)),
          );
        }
      }

      final listes = TabBarView(
        children: [
          _ListeAFaire(taches: store.aFaire, ouvrir: ouvrir, selection: _selection),
          _ListeSimple(
            taches: store.terminees.reversed.toList(),
            ouvrir: ouvrir,
            selection: _selection,
            vide: 'Aucune tâche terminée pour l’instant.',
          ),
        ],
      );

      if (!etendu) return listes;

      return Row(
        children: [
          Expanded(flex: 2, child: listes),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: _selection != null && store.tache(_selection!) != null
                ? TaskDetailView(
                    key: ValueKey(_selection),
                    taskId: _selection!,
                    apresSuppression: () => setState(() => _selection = null),
                  )
                : const _AucuneSelection(),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Échéances'),
          actions: [
            IconButton(
              tooltip: 'Actualiser',
              icon: const Icon(Icons.refresh),
              onPressed: store.chargement ? null : store.charger,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'À faire (${store.aFaire.length})'),
              Tab(text: 'Terminées (${store.terminees.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(fullscreenDialog: true, builder: (_) => const TaskFormScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle tâche'),
        ),
        body: switch ((store.chargement, store.erreur)) {
          // 1. En cours
          (true, _) => const Center(child: CircularProgressIndicator(semanticsLabel: 'Chargement')),
          // 3. Erreur : message et bouton réessayer
          (_, final String message) => _Erreur(message: message, reessayer: store.charger),
          // 2. Valeur
          _ => LayoutBuilder(builder: contenu),
        },
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
