import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final User user;
}
