# CampusFlow

Application mobile Flutter de suivi des **cours, échéances et tâches** d'un étudiant.
TP de Programmation Mobile, Master 1 (M. Compaoré), année 2026-2027.

Le projet a été construit séance par séance : chaque étape a son commit (voir l'historique Git).

| Séance | Sujet | Où le trouver |
|---|---|---|
| 1 | Écosystème mobile : fiche comparative, autopsie, décision | [`docs/seance-1/`](docs/seance-1/) |
| 2 | UX/UI : persona, parcours, wireframes, design system | [`docs/seance-2/`](docs/seance-2/) |
| 3 | Dart : modèles Task, Course, User, `fromJson`, tests | [`campusflow_models/`](campusflow_models/) |
| 4 | Projet Flutter, thème, asset | [`lib/core/theme.dart`](lib/core/theme.dart), [`assets/`](assets/), [`docs/flutter-doctor.txt`](docs/flutter-doctor.txt) |
| 5 | Écrans, layout, responsive (840 dp) | [`lib/features/*/presentation/`](lib/features/) |
| 6 | Navigation go_router, état Riverpod, filtres | [`lib/core/router.dart`](lib/core/router.dart), [`lib/features/taches/application/`](lib/features/taches/application/) |
| 7 | API json-server, couches, CRUD, connexion par jeton | [`server/`](server/), [`lib/core/`](lib/core/), [`lib/features/*/data/`](lib/features/) |

Captures sur l'émulateur Android : [`docs/captures/`](docs/captures/).

## Lancer le projet

**Prérequis :** Flutter 3.47 ou plus (`flutter doctor`), Node.js (pour le serveur), Android Studio et un émulateur pour Android.

Le plus simple sous Windows : double-cliquer sur **`lancer.bat`** et choisir une option. Il démarre le serveur API dans sa propre fenêtre, puis l'application.

À la main :

```bash
# 1. Le serveur API (port 3000)
cd server
npm install
npm start

# 2. L'application, dans un autre terminal
flutter pub get
flutter run -d chrome     # ou : flutter run (émulateur Android)
```

**Compte de démonstration :** `amina@etudiant.bf` / `campus`

Sur l'émulateur Android, l'application joint le serveur du PC par `http://10.0.2.2:3000` (et non `localhost`). Sur un téléphone réel : `flutter run --dart-define=API_URL=http://<adresse-du-PC>:3000`.

## Tests

```bash
flutter test                    # 24 tests de l'application, sans serveur
cd campusflow_models && dart test   # 4 tests des modèles
```

Les tests remplacent le serveur par des dépôts en mémoire (`FakeTaskRepository`, `FakeAuthRepository`) injectés par Riverpod, et vérifient les requêtes HTTP avec un faux réseau Dio.

## Architecture

```text
lib/
├── core/                 partagé : client Dio, intercepteur, routes, thème, stockage du jeton
└── features/
    ├── auth/             connexion : data (API /login), application (session), presentation (écran)
    ├── taches/           domain (contrat TaskRepository, règles), data (API + Fake),
    │                     application (TachesNotifier, filtres), presentation (écrans)
    ├── cours/
    └── profil/
campusflow_models/        package Dart des modèles (séance 3)
server/                   API simulée : json-server + connexion par jeton
docs/                     livrables de conception et captures
```

Flux d'une action : l'écran appelle le Notifier (`ref.read`) → le Notifier appelle le Repository → le Repository envoie la requête avec Dio → l'intercepteur ajoute `Authorization: Bearer <jeton>` → la réponse JSON devient un objet `Task` (`fromJson`) → nouvel état, les écrans se reconstruisent (`ref.watch`). Une réponse 401 déconnecte et ramène à `/login`.

## Choix techniques

- **Flutter** pour une seule base de code Android et iOS (décision : [`docs/seance-1/decision-campusflow.md`](docs/seance-1/decision-campusflow.md)).
- **Riverpod** pour l'état partagé, **go_router** pour la navigation par adresse.
- **Dio** pour HTTP, **flutter_secure_storage** pour le jeton (Keystore / Keychain), jamais en clair.
- `server/server.js` utilise json-server comme bibliothèque pour ajouter `/login` et la réponse 401, que `json-server db.json` seul ne sait pas faire.
- HTTP en clair autorisé **en debug seulement** sur Android, pour le serveur local.
