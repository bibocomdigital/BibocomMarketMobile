import 'package:bibomarketmobile/core/utils/json_utils.dart';
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
    final tokens = asJsonMap(json['tokens']);
    final token = asString(
      json['token'] ?? json['access'] ?? tokens['access'],
    );
    return AuthResponseModel(
      token: token,
      user: UserModel.fromJson(asJsonMap(json['user'])),
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
