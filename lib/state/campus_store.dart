import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

/// État de l'application. Les écrans le lisent avec `CampusScope.of(context)`
/// et se reconstruisent à chaque `notifyListeners()`.
///
/// Les tâches ne sont jamais modifiées sur place : on remplace l'objet par sa
/// copie (`copyWith`), comme le fera Riverpod plus tard.
class CampusStore extends ChangeNotifier {
  CampusStore({TaskRepository? repository})
      : _repository = repository ?? const FakeTaskRepository();

  final TaskRepository _repository;

  User? utilisateur;
  List<Task> taches = [];

  // Les trois états d'un Future (séance 3) : en cours, valeur, erreur.
  bool chargement = false;
  String? erreur;

  // Préférences
  bool rappelsActives = true;
  bool themeSombre = false;

  final List<Course> cours = const [
    Course(id: 'mobile', nom: 'Programmation mobile', enseignant: 'M. Compaoré'),
    Course(id: 'ux', nom: 'UX/UI mobile', enseignant: 'M. Compaoré'),
    Course(id: 'bdd', nom: 'Bases de données', enseignant: 'Mme Kaboré'),
  ];

  Course coursDe(String id) => cours.firstWhere(
        (c) => c.id == id,
        orElse: () => Course(id: id, nom: id, enseignant: '—'),
      );

  Task? tache(String id) {
    for (final t in taches) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Task> get aFaire => taches.where((t) => !t.terminee).toList();
  List<Task> get terminees => taches.where((t) => t.terminee).toList();

  /// Connexion simulée : pas de serveur pour l'instant.
  Future<void> connecter(String email) async {
    final prenom = email.split('@').first.split('.').first;
    utilisateur = User(
      id: 'u1',
      nom: prenom.isEmpty ? 'Étudiant' : prenom[0].toUpperCase() + prenom.substring(1),
      email: email,
      niveau: 'Master 1 Informatique',
    );
    notifyListeners();
    await charger();
  }

  void deconnecter() {
    utilisateur = null;
    taches = [];
    erreur = null;
    notifyListeners();
  }

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      taches = await _repository.chargerTaches();
      _trier();
    } catch (e) {
      erreur = 'Impossible de charger les échéances. Vérifie ta connexion.';
    } finally {
      chargement = false;
      notifyListeners();
    }
  }

  void basculer(String id) {
    final t = tache(id);
    if (t == null) return;
    enregistrer(t.copyWith(terminee: !t.terminee));
  }

  /// Ajoute la tâche, ou remplace celle qui a le même id.
  void enregistrer(Task t) {
    final i = taches.indexWhere((x) => x.id == t.id);
    taches = [...taches];
    if (i == -1) {
      taches.add(t);
    } else {
      taches[i] = t;
    }
    _trier();
    notifyListeners();
  }

  void supprimer(String id) {
    taches = taches.where((t) => t.id != id).toList();
    notifyListeners();
  }

  void changerRappels(bool valeur) {
    rappelsActives = valeur;
    notifyListeners();
  }

  void changerTheme(bool sombre) {
    themeSombre = sombre;
    notifyListeners();
  }

  void _trier() => taches.sort((a, b) => a.echeance.compareTo(b.echeance));
}

/// Donne accès au [CampusStore] à tout l'arbre de widgets.
class CampusScope extends InheritedNotifier<CampusStore> {
  const CampusScope({super.key, required CampusStore store, required super.child})
      : super(notifier: store);

  static CampusStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CampusScope>()!.notifier!;
}
