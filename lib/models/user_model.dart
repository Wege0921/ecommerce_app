class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isAdmin: json['is_admin'] ?? false,
    );
  }
}
