import 'package:campusflow_models/campusflow_models.dart' show Task;

// Logique métier de CampusFlow : du Dart pur, aucune dépendance à Flutter
// ni au réseau, donc testable seule. (La règle « en retard » est Task.enRetard.)

/// Les échéances les plus proches d'abord. Renvoie une nouvelle liste.
List<Task> trierParEcheance(List<Task> taches) =>
    [...taches]..sort((a, b) => a.echeance.compareTo(b.echeance));
