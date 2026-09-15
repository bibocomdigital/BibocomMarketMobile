import 'package:bibomarketmobile/core/network/api_envelope.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';

class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: asInt(json['id']),
      email: asString(json['email']),
      firstName: asString(json['firstName']),
      lastName: asString(json['lastName']),
      role: asString(json['role'], fallback: 'CLIENT'),
      phoneNumber: json['phoneNumber']?.toString(),
      photo: json['photo']?.toString(),
      whatsappNumber: json['whatsappNumber']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      gender: json['gender']?.toString(),
      language: asString(json['language'], fallback: 'fr'),
      currency: asString(json['currency'], fallback: 'CFA'),
      timezone: asString(json['timezone'], fallback: 'Africa/Dakar'),
      isVerified: asBool(json['isVerified']),
      profileCompletion: asInt(json['profileCompletion']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'phoneNumber': phoneNumber,
        'photo': photo,
        'whatsappNumber': whatsappNumber,
        'city': city,
        'country': country,
        'gender': gender,
        'language': language,
        'currency': currency,
        'timezone': timezone,
        'isVerified': isVerified,
        'profileCompletion': profileCompletion,
      };

  User toEntity() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
        photo: photo,
        whatsappNumber: whatsappNumber,
        city: city,
        country: country,
        gender: gender,
        language: language,
        currency: currency,
        timezone: timezone,
        isVerified: isVerified,
        profileCompletion: profileCompletion,
      );
}
