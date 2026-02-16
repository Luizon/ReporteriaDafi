class User {
  final int id;
  final String username;
  final String name;
  final String lastName;
  final String position;
  final String role;
  final DateTime birthDate;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.lastName,
    required this.position,
    required this.role,
    required this.birthDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      lastName: json['lastName'] as String,
      position: json['position'] as String,
      role: json['role'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'lastName': lastName,
      'position': position,
      'role': role,
      'birthDate': birthDate.toIso8601String(),
    };
  }
}