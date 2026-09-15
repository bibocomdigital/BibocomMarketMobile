import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/utils/json_utils.dart';
import 'package:bibomarketmobile/features/auth/data/models/auth_response_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/login_request_model.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login(LoginRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: body.toJson(),
    );
    return AuthResponseModel.fromJson(asJsonMap(response.data));
  }

  Future<AuthResponseModel> loginWithGoogle(GoogleAuthRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.googleAuth,
      data: body.toJson(),
    );
    return AuthResponseModel.fromJson(asJsonMap(response.data));
  }

  Future<void> register(RegisterParams params) async {
    await _dio.post<dynamic>(
      ApiEndpoints.register,
      data: {
        'email': params.email,
        'password': params.password,
        'firstName': params.firstName,
        'lastName': params.lastName,
        'phoneNumber': params.phoneNumber,
        'role': 'MERCHANT',
      },
    );
  }
}
