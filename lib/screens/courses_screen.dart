import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../state/campus_store.dart';
import '../theme.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';

/// Plan : Cours → liste des cours → tâches du cours.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);
    final couleurs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cours')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Tokens.s),
        children: [
          for (final c in store.cours)
            Card(
              child: ListTile(
                minVerticalPadding: 12,
                leading: CircleAvatar(
                  backgroundColor: couleurs.primaryContainer,
                  child: Text(c.nom[0], style: TextStyle(color: couleurs.onPrimaryContainer)),
                ),
                title: Text(c.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c.enseignant),
                trailing: _Compteur(
                  nombre: store.aFaire.where((t) => t.coursId == c.id).length,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CourseTasksScreen(course: c)),
                ),
              ),
            ),
        ],
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

/// Tâches d'un cours, à faire puis terminées.
class CourseTasksScreen extends StatelessWidget {
  const CourseTasksScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);
    final taches = store.taches.where((t) => t.coursId == course.id).toList()
      ..sort((a, b) => a.terminee == b.terminee ? 0 : (a.terminee ? 1 : -1));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(course.nom)),
      body: taches.isEmpty
          ? Center(child: Text('Aucune tâche pour ce cours.', style: theme.textTheme.bodyLarge))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: Tokens.s),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Tokens.m, 0, Tokens.m, Tokens.s),
                  child: Text(
                    course.enseignant,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                for (final t in taches)
                  TaskCard(
                    task: t,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)),
                    ),
                  ),
              ],
            ),
    );
  }
}
