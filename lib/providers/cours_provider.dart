import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cours de l'étudiant (en dur jusqu'à l'API de la séance 7).
final coursProvider = Provider<List<Course>>((ref) => const [
      Course(id: 'mobile', nom: 'Programmation mobile', enseignant: 'M. Compaoré'),
      Course(id: 'ux', nom: 'UX/UI mobile', enseignant: 'M. Compaoré'),
      Course(id: 'bdd', nom: 'Bases de données', enseignant: 'Mme Kaboré'),
    ]);

final coursParIdProvider = Provider.family<Course, String>((ref, id) {
  for (final c in ref.watch(coursProvider)) {
    if (c.id == id) return c;
  }
  return Course(id: id, nom: id, enseignant: '—');
});
