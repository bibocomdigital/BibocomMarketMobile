import 'package:bibomarketmobile/features/auth/data/models/user_model.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.token,
    required this.user,
  });

  final String token;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
      };

  AuthSession toEntity() => AuthSession(
        token: token,
        user: user.toEntity(),
      );
}
