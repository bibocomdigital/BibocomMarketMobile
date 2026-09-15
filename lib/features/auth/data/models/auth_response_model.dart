import 'package:bibomarketmobile/core/network/api_envelope.dart';
import 'package:bibomarketmobile/features/auth/data/models/user_model.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.token,
    required this.user,
  });

  final String token;
  final UserModel user;

  factory AuthResponseModel.fromJson(dynamic json) {
    final payload = unwrapApiMap(json);
    final tokens = asMap(payload['tokens']) ?? const {};
    final token = asString(
      payload['token'] ?? payload['access'] ?? tokens['access'],
    );
    final userJson = asMap(payload['user']) ?? payload;
    return AuthResponseModel(
      token: token,
      user: UserModel.fromJson(userJson),
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

  AuthResponseModel copyWithUser(UserModel user) => AuthResponseModel(
        token: token,
        user: user,
      );
}
