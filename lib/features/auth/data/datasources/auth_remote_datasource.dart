import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/features/auth/data/models/auth_response_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/login_request_model.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login(LoginRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: body.toJson(),
    );
    return AuthResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<AuthResponseModel> loginWithGoogle(GoogleAuthRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.googleAuth,
      data: body.toJson(),
    );
    return AuthResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
