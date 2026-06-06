import '../../domain/entities/user.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.token,
    required this.image,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String token;
  final String image;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      username: (json['username'] as String?) ?? '',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      token: (json['token'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
    );
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      token: token,
      image: image,
    );
  }
}
