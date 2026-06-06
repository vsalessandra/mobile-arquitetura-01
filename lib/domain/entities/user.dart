class User {
  User({
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

  String get fullName => '$firstName $lastName';
}
