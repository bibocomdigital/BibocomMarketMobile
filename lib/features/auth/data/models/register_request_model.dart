class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    required this.role,
    this.email,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final String role;
  final String? email;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'password': password,
        'role': role,
        if (email != null && email!.isNotEmpty) 'email': email,
      };
}
