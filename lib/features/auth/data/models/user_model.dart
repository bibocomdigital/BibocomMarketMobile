import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';

class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: asInt(json['id']),
      email: asString(json['email']),
      firstName: asString(json['firstName']),
      lastName: asString(json['lastName']),
      role: asString(json['role']),
      phoneNumber: json['phoneNumber']?.toString(),
      photo: json['photo']?.toString(),
      isVerified: asBool(json['isVerified'], true),
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
        'isVerified': isVerified,
      };

  User toEntity() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
        photo: photo,
        isVerified: isVerified,
      );
}
