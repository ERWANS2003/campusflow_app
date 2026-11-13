# campusflow_models

Package Dart pur de la **séance 3** : les données de CampusFlow, indépendamment de toute interface.

- **Trois modèles immuables** : `Task`, `Course`, `User`, avec des attributs `final`, un constructeur nommé, `copyWith`, `fromJson` et `toJson`.
- **Un dépôt simulé** : `FakeTaskRepository` renvoie des tâches après un `Future.delayed`, et peut simuler une coupure réseau.
- **Des tests** (`dart test`) : `copyWith`, `fromJson`, l'aller-retour JSON et une erreur attendue.

L'application Flutter (dossier parent) l'utilise comme dépendance locale : `campusflow_models: path: campusflow_models`.

```bash
dart test                                    # les tests
dart run example/campusflow_models_example.dart   # chargement simulé, succès puis erreur
```

Sous Windows, `lancer.bat` (texte) et `Lanceur.bat` (fenêtre) enchaînent dépendances, analyse, tests et exemple.
