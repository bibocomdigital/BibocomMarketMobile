import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/error/error_mapper.dart';
import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/storage/local_storage_service.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/login_request_model.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
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
  Future<Result<void>> register(RegisterParams params) async {
    try {
      await _remote.register(params);
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
      await _local.clear();
      return const Success(null);
    } catch (error) {
      return Err(ErrorMapper.map(error));
    }
  }
}
