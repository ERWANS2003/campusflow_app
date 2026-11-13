/// Un cours suivi par l'étudiant.
class Course {
  final String id;
  final String nom;
  final String enseignant;

  const Course({
    required this.id,
    required this.nom,
    required this.enseignant,
  });

  Course copyWith({String? nom, String? enseignant}) => Course(
        id: id,
        nom: nom ?? this.nom,
        enseignant: enseignant ?? this.enseignant,
      );

  factory Course.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nom = json['nom'];
    final enseignant = json['enseignant'];

    if (id is! String || nom is! String || enseignant is! String) {
      throw FormatException('Course invalide', json);
    }

    return Course(id: id, nom: nom, enseignant: enseignant);
  }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'enseignant': enseignant};

  @override
  String toString() => 'Course($nom, $enseignant)';
}
