/// L'étudiant connecté.
class User {
  final String id;
  final String nom;
  final String email;
  final String niveau; // ex. 'M1 Informatique'

  const User({
    required this.id,
    required this.nom,
    required this.email,
    required this.niveau,
  });

  User copyWith({String? nom, String? email, String? niveau}) => User(
        id: id,
        nom: nom ?? this.nom,
        email: email ?? this.email,
        niveau: niveau ?? this.niveau,
      );

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nom = json['nom'];
    final email = json['email'];
    final niveau = json['niveau'];

    if (id is! String || nom is! String || email is! String || niveau is! String) {
      throw FormatException('User invalide', json);
    }
    if (!email.contains('@')) {
      throw FormatException('Email invalide', email);
    }

    return User(id: id, nom: nom, email: email, niveau: niveau);
  }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'email': email, 'niveau': niveau};

  @override
  String toString() => 'User($nom, $email)';
}
