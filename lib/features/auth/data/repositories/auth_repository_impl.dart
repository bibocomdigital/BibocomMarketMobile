import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/error/error_mapper.dart';
import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/storage/local_storage_service.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/login_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/register_request_model.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required LocalStorageService prefs,
  })  : _remote = remote,
        _local = local,
        _prefs = prefs;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final LocalStorageService _prefs;

  @override
  Future<Result<AuthSession>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _remote.login(
        LoginRequestModel(
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        ),
      );
      await _local.cacheSession(response);
      return Success(response.toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<AuthSession>> loginWithGoogle(String idToken) async {
    try {
      final response = await _remote.loginWithGoogle(
        GoogleAuthRequestModel(idToken: idToken),
      );
      await _local.cacheSession(response);
      return Success(response.toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<String>> register(RegisterParams params) async {
    try {
      final message = await _remote.register(
        RegisterRequestModel(
          firstName: params.firstName,
          lastName: params.lastName,
          phoneNumber: params.phoneNumber,
          password: params.password,
          role: params.role,
          email: params.email.isEmpty ? null : params.email,
        ),
      );
      if (params.shopName != null && params.shopName!.trim().isNotEmpty) {
        await _prefs.setString(
          StorageKeys.pendingShopName,
          params.shopName!.trim(),
        );
      }
      if (params.shopSector != null && params.shopSector!.trim().isNotEmpty) {
        await _prefs.setString(
          StorageKeys.pendingShopSector,
          params.shopSector!.trim(),
        );
      }
      if (params.categorieShopId != null) {
        await _prefs.setString(
          StorageKeys.pendingShopCategoryId,
          '${params.categorieShopId}',
        );
      }
      if (params.phoneNumber.trim().isNotEmpty) {
        await _prefs.setString(
          StorageKeys.pendingShopPhone,
          params.phoneNumber.trim(),
        );
      }
      return Success(message);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _remote.verify(email: email, code: code);
      await _local.cacheSession(response);
      return Success(response.toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> getProfile() async {
    try {
      return Success((await _remote.getProfile()).toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> updateProfile(Map<String, dynamic> body) async {
    try {
      final model = await _remote.updateProfile(body);
      final cached = await _local.readSession();
      if (cached != null) {
        await _local.cacheSession(cached.copyWithUser(model));
      }
      return Success(model.toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<User>> uploadProfilePhoto(String path) async {
    try {
      await _remote.uploadProfilePhoto(path);
      final model = await _remote.getProfile();
      final cached = await _local.readSession();
      if (cached != null) {
        await _local.cacheSession(cached.copyWithUser(model));
      }
      return Success(model.toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> completePersonalInfo(Map<String, dynamic> body) async {
    try {
      await _remote.completePersonalInfo(body);
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      await _local.clear();
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final cached = await _local.readSession();
      return Success(cached?.toEntity());
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remote.logoutRemote();
      await _local.clear();
      return const Success(null);
    } catch (error) {
      await _local.clear();
      return Err(ErrorMapper.map(error));
    }
  }
}
