import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow_app/core/actions.dart';
import 'package:campusflow_app/features/cours/application/cours_provider.dart';
import 'package:campusflow_app/features/taches/application/taches_provider.dart';
import 'package:campusflow_app/core/theme.dart';
import 'package:campusflow_app/core/dates.dart';

/// Wireframe « Nouvelle tâche » : × Nouvelle tâche, Titre, Cours, Date, Rappel,
/// Enregistrer. Les valeurs par défaut permettent d'ajouter en 3 appuis :
/// bouton « Nouvelle tâche » → saisir le titre → Enregistrer.
/// Routes : /taches/nouvelle (création) et /taches/:id/modifier.
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  /// null = création, sinon id de la tâche à modifier.
  final String? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  static const _rappels = <Duration?>[
    null,
    Duration(hours: 1),
    Duration(hours: 3),
    Duration(days: 1),
    Duration(days: 2),
  ];

  final _form = GlobalKey<FormState>();
  late final TextEditingController _titre;
  late final TextEditingController _description;
  String? _coursId;
  late DateTime _echeance;
  Duration? _rappel;
  Task? _existante;
  bool _envoi = false; // requête en cours : bouton désactivé

  @override
  void initState() {
    super.initState();
    // read et non watch : on lit la tâche une fois pour pré-remplir le formulaire.
    final id = widget.taskId;
    final t = _existante = id == null ? null : ref.read(tacheParIdProvider(id));
    _titre = TextEditingController(text: t?.titre);
    _description = TextEditingController(text: t?.description);
    _coursId = t?.coursId;
    final demain = DateTime.now().add(const Duration(days: 1));
    _echeance = t?.echeance ?? DateTime(demain.year, demain.month, demain.day, 23, 59);
    _rappel = t == null ? const Duration(days: 1) : t.rappel;
  }

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _echeance,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final h = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_echeance));
    setState(() {
      final hh = h ?? TimeOfDay.fromDateTime(_echeance);
      _echeance = DateTime(date.year, date.month, date.day, hh.hour, hh.minute);
    });
  }

  Future<void> _enregistrer() async {
    if (!_form.currentState!.validate()) return;
    final description = _description.text.trim();
    final titre = _titre.text.trim();
    final messages = ScaffoldMessenger.of(context);
    setState(() => _envoi = true);
    // Nouvel objet complet plutôt que copyWith : permet de vider la description
    // ou de retirer le rappel (copyWith ne sait pas remettre un champ à null).
    final tache = Task(
      id: _existante?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      titre: titre,
      coursId: _coursId!,
      echeance: _echeance,
      description: description.isEmpty ? null : description,
      rappel: _rappel,
      terminee: _existante?.terminee ?? false,
    );
    // POST ou PATCH : on attend la réponse du serveur avant de fermer.
    final ok = await tenter(messages, () => ref.read(tachesProvider.notifier).enregistrer(tache));
    if (!mounted) return;
    setState(() => _envoi = false);
    if (!ok) return; // l'erreur est affichée, le formulaire reste ouvert
    // SnackBar : informe sans bloquer (séance 5).
    messages.showSnackBar(SnackBar(
      content: Text(_existante == null ? 'Tâche « $titre » ajoutée' : 'Tâche « $titre » modifiée'),
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cours = ref.watch(coursProvider).value ?? const <Course>[];
    _coursId ??= cours.isEmpty ? null : cours.first.id;
    final modification = _existante != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Fermer',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(modification ? 'Modifier la tâche' : 'Nouvelle tâche'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(Tokens.m),
          children: [
            TextFormField(
              controller: _titre,
              autofocus: !modification,
              decoration: const InputDecoration(labelText: 'Titre', hintText: 'ex. Rendu TP Dart'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Le titre est obligatoire.' : null,
            ),
            const SizedBox(height: Tokens.m),
            DropdownButtonFormField<String>(
              key: ValueKey(cours.length), // recréé quand la liste arrive du serveur
              initialValue: _coursId,
              decoration: const InputDecoration(labelText: 'Cours'),
              items: [
                for (final c in cours) DropdownMenuItem(value: c.id, child: Text(c.nom)),
              ],
              onChanged: (v) => setState(() => _coursId = v),
              validator: (v) => v == null ? 'Choisis un cours.' : null,
            ),
            const SizedBox(height: Tokens.m),
            InkWell(
              borderRadius: BorderRadius.circular(Tokens.rayon),
              onTap: _choisirDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(dateLongue(_echeance)),
              ),
            ),
            const SizedBox(height: Tokens.m),
            DropdownButtonFormField<Duration?>(
              initialValue: _rappel,
              decoration: const InputDecoration(labelText: 'Rappel'),
              items: [
                for (final r in _rappels) DropdownMenuItem(value: r, child: Text(libelleRappel(r))),
              ],
              onChanged: (v) => setState(() => _rappel = v),
            ),
            const SizedBox(height: Tokens.m),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description (facultative)', alignLabelWithHint: true),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: Tokens.l),
            FilledButton(
              onPressed: _envoi ? null : _enregistrer, // null désactive le bouton
              child: _envoi
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
