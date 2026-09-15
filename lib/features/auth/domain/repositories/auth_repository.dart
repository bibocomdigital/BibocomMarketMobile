import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<Result<AuthSession>> loginWithGoogle(String idToken);

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<void>> logout();
}
