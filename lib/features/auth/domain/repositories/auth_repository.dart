import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';

class RegisterParams {
  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    this.email = '',
    this.role = UserRoles.client,
    this.shopName,
    this.shopSector,
    this.categorieShopId,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String? shopName;
  final String? shopSector;
  final int? categorieShopId;
}

abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<Result<AuthSession>> loginWithGoogle(String idToken);

  Future<Result<String>> register(RegisterParams params);

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
