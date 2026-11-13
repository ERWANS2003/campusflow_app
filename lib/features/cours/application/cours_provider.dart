import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/core/dio_provider.dart';
import 'package:campusflow_app/features/auth/application/session_provider.dart';
import 'package:campusflow_app/features/cours/data/cours_repository.dart';

final coursRepositoryProvider = Provider<CoursRepository>(
  (ref) => ApiCoursRepository(ref.watch(dioProvider)),
);

/// Cours de l'étudiant, lus depuis l'API (GET /cours) une fois connecté.
final coursProvider = FutureProvider<List<Course>>((ref) async {
  if (ref.watch(sessionProvider.select((s) => s.value?.id)) == null) return const [];
  return ref.watch(coursRepositoryProvider).lister();
});

/// Un cours par son id. Tant que la liste n'est pas arrivée, l'id sert de nom.
final coursParIdProvider = Provider.family<Course, String>((ref, id) {
  for (final c in ref.watch(coursProvider).value ?? const <Course>[]) {
    if (c.id == id) return c;
  }
  return Course(id: id, nom: id, enseignant: '—');
});
