class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final List<String> favorites;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.favorites = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? 'Pengguna',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'favorites': favorites,
    };
  }
}