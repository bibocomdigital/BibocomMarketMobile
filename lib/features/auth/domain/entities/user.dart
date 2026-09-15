class User {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.photo,
    this.isVerified = false,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;
  final String? photo;
  final bool isVerified;

  String get displayName => '$firstName $lastName'.trim();
}
