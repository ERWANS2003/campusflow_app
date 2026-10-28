import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../state/campus_store.dart';
import '../utils/dates.dart';

/// Composant « carte de tâche » du design system.
/// La case à cocher permet de marquer comme fait sans ouvrir le détail.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap, this.selectionnee = false});

  final Task task;
  final VoidCallback onTap;
  final bool selectionnee;

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);
    final couleurs = Theme.of(context).colorScheme;
    final cours = store.coursDe(task.coursId);
    final quand = '${jourRelatif(task.echeance)} · ${heure(task.echeance)}';

    return Card(
      color: selectionnee ? couleurs.secondaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        label: '${task.titre}, ${cours.nom}, échéance ${dateLongue(task.echeance)}'
            '${task.enRetard ? ', en retard' : ''}${task.terminee ? ', faite' : ''}',
        excludeSemantics: false,
        child: ListTile(
          minVerticalPadding: 12,
          onTap: onTap,
          leading: Checkbox(
            value: task.terminee,
            semanticLabel: task.terminee
                ? 'Marquer « ${task.titre} » à faire'
                : 'Marquer « ${task.titre} » comme fait',
            onChanged: (_) => store.basculer(task.id),
          ),
          title: Text(
            task.titre,
            style: task.terminee
                ? TextStyle(decoration: TextDecoration.lineThrough, color: couleurs.onSurfaceVariant)
                : const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            task.enRetard ? '${cours.nom} · en retard ($quand)' : '${cours.nom} · $quand',
            style: task.enRetard ? TextStyle(color: couleurs.error) : null,
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
