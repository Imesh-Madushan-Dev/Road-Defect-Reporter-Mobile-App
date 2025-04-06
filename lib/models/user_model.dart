class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  // Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'isAdmin': isAdmin};
  }
}
