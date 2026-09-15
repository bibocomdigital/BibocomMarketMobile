import 'package:bibomarketmobile/core/error/exceptions.dart';
import 'package:bibomarketmobile/core/error/failures.dart';
import 'package:dio/dio.dart';

abstract final class ErrorMapper {
  static Failure map(Object error) {
    if (error is Failure) return error;

    if (error is AppException) {
      return switch (error) {
        ServerException() => ServerFailure(error.message),
        NetworkException() => NetworkFailure(error.message),
        UnauthorizedException() => AuthFailure(error.message),
        CacheException() => CacheFailure(error.message),
      };
    }

    if (error is DioException) {
      return _fromDio(error);
    }

    return UnknownFailure(error.toString());
  }

  static Failure _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        final message = _messageFromBody(error.response?.data);
        if (status == 401 || status == 403) {
          return AuthFailure(message ?? 'Identifiants invalides.');
        }
        return ServerFailure(message ?? 'Erreur serveur ($status).');
      case DioExceptionType.cancel:
        return const UnknownFailure('Requête annulée.');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Certificat SSL invalide.');
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return UnknownFailure(error.message ?? 'Erreur inconnue.');
    }
  }

  static String? _messageFromBody(Object? data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
