import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.shopName,
    this.shopSector,
    this.categorieShopId,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
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

  Future<Result<void>> register(RegisterParams params);

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<void>> logout();
}
