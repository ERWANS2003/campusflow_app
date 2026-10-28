import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../state/campus_store.dart';
import '../theme.dart';
import '../utils/dates.dart';

/// Wireframe « Nouvelle tâche » : × Nouvelle tâche, Titre, Cours, Date, Rappel,
/// Enregistrer. Les valeurs par défaut permettent d'ajouter en 3 appuis :
/// bouton « Nouvelle tâche » → saisir le titre → Enregistrer.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.existante});

  /// null = création, sinon modification.
  final Task? existante;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
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

  @override
  void initState() {
    super.initState();
    final t = widget.existante;
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

  void _enregistrer() {
    if (!_form.currentState!.validate()) return;
    final store = CampusScope.of(context);
    final description = _description.text.trim();
    // Nouvel objet complet plutôt que copyWith : permet de vider la description
    // ou de retirer le rappel (copyWith ne sait pas remettre un champ à null).
    store.enregistrer(Task(
      id: widget.existante?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      titre: _titre.text.trim(),
      coursId: _coursId ?? store.cours.first.id,
      echeance: _echeance,
      description: description.isEmpty ? null : description,
      rappel: _rappel,
      terminee: widget.existante?.terminee ?? false,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = CampusScope.of(context);
    final modification = widget.existante != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Fermer',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
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
              initialValue: _coursId ?? store.cours.first.id,
              decoration: const InputDecoration(labelText: 'Cours'),
              items: [
                for (final c in store.cours) DropdownMenuItem(value: c.id, child: Text(c.nom)),
              ],
              onChanged: (v) => setState(() => _coursId = v),
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
            FilledButton(onPressed: _enregistrer, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}
