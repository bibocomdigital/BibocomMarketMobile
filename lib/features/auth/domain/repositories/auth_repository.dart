import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<Result<AuthSession>> loginWithGoogle(String idToken);

  Future<Result<String>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required String role,
    String? email,
  });

  Future<Result<AuthSession>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Result<User>> getProfile();

  Future<Result<User>> updateProfile(Map<String, dynamic> body);

  Future<Result<void>> completePersonalInfo(Map<String, dynamic> body);

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> deleteAccount();

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<void>> logout();
}
