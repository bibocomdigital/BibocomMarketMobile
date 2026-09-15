import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/network/api_envelope.dart';
import 'package:bibomarketmobile/features/auth/data/models/auth_response_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/google_auth_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/login_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/register_request_model.dart';
import 'package:bibomarketmobile/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login(LoginRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: body.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> loginWithGoogle(GoogleAuthRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.googleAuth,
      data: body.toJson(),
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<String> register(RegisterRequestModel body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.register,
      data: body.toJson(),
    );
    final map = unwrapApiMap(response.data);
    return asString(
      map['message'],
      fallback: 'Inscription réussie. Vous pouvez maintenant vous connecter.',
    );
  }

  Future<AuthResponseModel> verify({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.verify,
      data: {'email': email, 'verificationCode': code},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.usersProfile);
    final map = unwrapApiMap(response.data);
    return UserModel.fromJson(asMap(map['user']) ?? map);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> body) async {
    final response = await _dio.put<dynamic>(
      ApiEndpoints.usersProfile,
      data: body,
    );
    final map = unwrapApiMap(response.data);
    return UserModel.fromJson(asMap(map['user']) ?? map);
  }

  Future<void> completePersonalInfo(Map<String, dynamic> body) async {
    await _dio.post<dynamic>(ApiEndpoints.onboardingPersonal, data: body);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put<dynamic>(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> deleteAccount() async {
    await _dio.delete<dynamic>(ApiEndpoints.deleteAccount);
  }

  Future<void> logoutRemote() async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.logout);
    } catch (_) {}
  }
}
