class User {
  const User({
    required this.id,
    required this.role,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.photo,
    this.whatsappNumber,
    this.city,
    this.country,
    this.gender,
    this.language = 'fr',
    this.currency = 'CFA',
    this.timezone = 'Africa/Dakar',
    this.isVerified = false,
    this.profileCompletion = 0,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;
  final String? photo;
  final String? whatsappNumber;
  final String? city;
  final String? country;
  final String? gender;
  final String language;
  final String currency;
  final String timezone;
  final bool isVerified;
  final int profileCompletion;

  bool get isClient =>
      role.toUpperCase() == 'CLIENT' || role.toUpperCase() == 'CUSTOMER';

  bool get isMerchant =>
      role.toUpperCase() == 'MERCHANT' || role.toUpperCase() == 'COMMERCANT';

  String get displayName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    return isMerchant ? 'Commerçant' : 'Client';
  }
}
