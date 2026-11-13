import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow_app/features/cours/application/cours_provider.dart';
import 'package:campusflow_app/features/taches/application/taches_provider.dart';
import 'package:campusflow_app/core/theme.dart';
import 'package:campusflow_app/features/taches/presentation/task_card.dart';

/// Route /cours : liste des cours → /cours/:id (tâches du cours).
class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(coursProvider); // GET /cours
    final aFaire = ref.watch(tachesFiltreesProvider(Filtre.aFaire));
    final couleurs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cours')),
      body: etat.when(
        loading: () => const Center(child: CircularProgressIndicator(semanticsLabel: 'Chargement')),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: Tokens.m),
              FilledButton(onPressed: () => ref.invalidate(coursProvider), child: const Text('Réessayer')),
            ],
          ),
        ),
        data: (cours) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: Tokens.s),
          itemCount: cours.length,
          itemBuilder: (context, i) {
            final c = cours[i];
            return Card(
              child: ListTile(
                minVerticalPadding: 12,
                leading: CircleAvatar(
                  backgroundColor: couleurs.primaryContainer,
                  child: Text(c.nom[0], style: TextStyle(color: couleurs.onPrimaryContainer)),
                ),
                title: Text(c.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c.enseignant),
                trailing: _Compteur(nombre: aFaire.where((t) => t.coursId == c.id).length),
                onTap: () => context.go('/cours/${c.id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({required this.nombre});

  final int nombre;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (nombre > 0)
          Badge.count(
            count: nombre,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        const SizedBox(width: Tokens.s),
        Semantics(
          label: '$nombre à faire',
          child: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

/// Route /cours/:id : tâches d'un cours, à faire puis terminées.
class CourseTasksScreen extends ConsumerWidget {
  const CourseTasksScreen({super.key, required this.coursId});

  final String coursId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(coursParIdProvider(coursId));
    final toutes = ref.watch(tachesProvider).value ?? const [];
    final taches = [
      for (final t in toutes)
        if (t.coursId == coursId && !t.terminee) t,
      for (final t in toutes)
        if (t.coursId == coursId && t.terminee) t,
    ];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(course.nom)),
      body: taches.isEmpty
          ? Center(child: Text('Aucune tâche pour ce cours.', style: theme.textTheme.bodyLarge))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: Tokens.s),
              itemCount: taches.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(Tokens.m, 0, Tokens.m, Tokens.s),
                    child: Text(
                      course.enseignant,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                final t = taches[i - 1];
                return TaskCard(
                  task: t,
                  onTap: () => context.go('/cours/$coursId/taches/${t.id}'),
                );
              },
            ),
    );
  }
}
