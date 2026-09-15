import 'package:bibomarketmobile/core/error/error_mapper.dart';
import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/login_request_model.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remote,
    required this._local,
  });

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

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
