import 'package:bibomarketmobile/config/env/app_env.dart';
import 'package:bibomarketmobile/core/network/interceptors/auth_interceptor.dart';
import 'package:bibomarketmobile/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract final class DioClient {
  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage));

    if (!AppEnv.isRelease) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }
}
