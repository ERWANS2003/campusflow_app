import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow_app/core/demarrage_screen.dart';
import 'package:campusflow_app/features/auth/application/session_provider.dart';
import 'package:campusflow_app/features/cours/presentation/courses_screen.dart';
import 'package:campusflow_app/features/taches/presentation/deadlines_screen.dart';
import 'package:campusflow_app/core/home_shell.dart';
import 'package:campusflow_app/features/auth/presentation/login_screen.dart';
import 'package:campusflow_app/features/profil/presentation/profile_screen.dart';
import 'package:campusflow_app/features/taches/presentation/task_detail_screen.dart';
import 'package:campusflow_app/features/taches/presentation/task_form_screen.dart';

/// Routes de CampusFlow (séance 6) :
///
/// | Chemin                     | Écran                     | Niveau              |
/// |----------------------------|---------------------------|---------------------|
/// | /login                     | Connexion                 | hors barre          |
/// | /taches                    | Échéances                 | destination 1       |
/// | /taches/nouvelle           | Formulaire de création    | secondaire          |
/// | /taches/:id                | Détail                    | secondaire          |
/// | /taches/:id/modifier       | Formulaire de modification| secondaire          |
/// | /cours                     | Liste des cours           | destination 2       |
/// | /cours/:id                 | Tâches du cours           | secondaire          |
/// | /profil                    | Compte et préférences     | destination 3       |
///
/// Les écrans secondaires sont des sous-routes : `context.go('/taches/t1')`
/// construit la pile /taches → /taches/t1, l'adresse change et le bouton retour
/// fonctionne. (`context.push` empile un écran sans changer l'adresse.)
final _racine = GlobalKey<NavigatorState>(debugLabel: 'racine');

final routerProvider = Provider<GoRouter>((ref) {
  // Le routeur réévalue `redirect` à chaque changement de session :
  // connexion, déconnexion, jeton expiré (401).
  final changements = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => changements.value++);
  ref.onDispose(changements.dispose);

  return GoRouter(
    navigatorKey: _racine,
    initialLocation: '/taches',
    refreshListenable: changements,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final ici = state.matchedLocation;
      // Au lancement, on vérifie le jeton enregistré : écran d'attente.
      if (session.isLoading && !session.hasValue) return ici == '/demarrage' ? null : '/demarrage';
      final connecte = session.value != null;
      if (!connecte) return ici == '/login' ? null : '/login';
      if (ici == '/login' || ici == '/demarrage') return '/taches';
      return null;
    },
    routes: [
      GoRoute(path: '/demarrage', builder: (_, _) => const DemarrageScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

      // Les trois destinations de la barre. Chaque branche garde sa propre pile :
      // revenir sur un onglet retrouve l'écran où on l'avait laissé.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/taches',
              builder: (_, _) => const DeadlinesScreen(),
              routes: [
                // « nouvelle » est déclaré AVANT :id, sinon il serait lu comme un id.
                // Les formulaires s'ouvrent sur le navigateur racine : plein écran,
                // par-dessus la barre de navigation.
                GoRoute(
                  path: 'nouvelle',
                  parentNavigatorKey: _racine,
                  pageBuilder: (_, state) => MaterialPage(
                    key: state.pageKey,
                    fullscreenDialog: true,
                    child: const TaskFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => TaskDetailScreen(taskId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'modifier',
                      parentNavigatorKey: _racine,
                      pageBuilder: (_, state) => MaterialPage(
                        key: state.pageKey,
                        fullscreenDialog: true,
                        child: TaskFormScreen(taskId: state.pathParameters['id']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/cours',
              builder: (_, _) => const CoursesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => CourseTasksScreen(coursId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'taches/:tacheId',
                      builder: (_, state) =>
                          TaskDetailScreen(taskId: state.pathParameters['tacheId']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profil', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
