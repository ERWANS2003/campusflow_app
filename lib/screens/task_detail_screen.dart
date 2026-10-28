import 'package:flutter/material.dart';

import '../state/campus_store.dart';
import '../theme.dart';
import '../utils/dates.dart';
import 'task_form_screen.dart';

/// Wireframe « Détail » en plein écran (téléphone) : « ← Projet Flutter ».
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final task = CampusScope.of(context).tache(taskId);
    return Scaffold(
      appBar: AppBar(title: Text(task?.titre ?? 'Tâche')),
      body: TaskDetailView(
        taskId: taskId,
        apresSuppression: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Contenu du détail, réutilisé à droite de la liste en fenêtre étendue.
/// Cours, échéance, rappel, description, puis « Marquer comme fait » et « Modifier ».
class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key, required this.taskId, required this.apresSuppression});

  final String taskId;
  final VoidCallback apresSuppression;

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);
    final task = store.tache(taskId);
    if (task == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cours = store.coursDe(task.coursId);

    Future<void> supprimer() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Supprimer la tâche ?'),
          content: Text('« ${task.titre} » sera définitivement supprimée.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
          ],
        ),
      );
      if (ok == true) {
        store.supprimer(task.id);
        apresSuppression();
      }
    }

    return ListView(
      padding: const EdgeInsets.all(Tokens.l),
      children: [
        Text(task.titre, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Tokens.s),
        if (task.terminee)
          const _Pastille(texte: 'Faite', icone: Icons.check_circle)
        else if (task.enRetard)
          _Pastille(texte: 'En retard', icone: Icons.warning_amber, couleur: theme.colorScheme.error),
        const SizedBox(height: Tokens.m),
        _Ligne(icone: Icons.school_outlined, libelle: 'Cours', valeur: '${cours.nom} · ${cours.enseignant}'),
        _Ligne(icone: Icons.event_outlined, libelle: 'Échéance', valeur: dateLongue(task.echeance)),
        _Ligne(
          icone: Icons.notifications_outlined,
          libelle: 'Rappel',
          valeur: store.rappelsActives ? libelleRappel(task.rappel) : 'Rappels désactivés',
        ),
        const Divider(height: Tokens.l * 2),
        Text('Description', style: theme.textTheme.titleMedium),
        const SizedBox(height: Tokens.s),
        Text(
          task.description ?? 'Aucune description.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: task.description == null ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        const SizedBox(height: Tokens.l * 1.5),
        FilledButton.icon(
          onPressed: () => store.basculer(task.id),
          icon: Icon(task.terminee ? Icons.undo : Icons.check),
          label: Text(task.terminee ? 'Marquer à faire' : 'Marquer comme fait'),
        ),
        const SizedBox(height: Tokens.s),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(fullscreenDialog: true, builder: (_) => TaskFormScreen(existante: task)),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier'),
        ),
        const SizedBox(height: Tokens.s),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            minimumSize: const Size(64, Tokens.cible),
          ),
          onPressed: supprimer,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Supprimer'),
        ),
      ],
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({required this.icone, required this.libelle, required this.valeur});

  final IconData icone;
  final String libelle;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Tokens.s),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: theme.colorScheme.primary),
            const SizedBox(width: Tokens.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(libelle, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  Text(valeur, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.texte, required this.icone, this.couleur});

  final String texte;
  final IconData icone;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final c = couleur ?? Theme.of(context).colorScheme.primary;
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(icone, color: c, size: 18),
        label: Text(texte, style: TextStyle(color: c)),
        side: BorderSide(color: c),
      ),
    );
  }
}
