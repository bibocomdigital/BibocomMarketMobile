class LoginRequestModel {
  const LoginRequestModel({
    this.email,
    this.phoneNumber,
    required this.password,
  });

  final String? email;
  final String? phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => {
        if (email != null && email!.isNotEmpty) 'email': email,
        if (phoneNumber != null && phoneNumber!.isNotEmpty)
          'phoneNumber': phoneNumber,
        'password': password,
      };
}
