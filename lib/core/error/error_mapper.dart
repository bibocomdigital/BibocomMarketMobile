import 'package:bibomarketmobile/core/error/exceptions.dart';
import 'package:bibomarketmobile/core/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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

    if (error is PlatformException) {
      return _fromPlatform(error);
    }

    if (error is DioException) {
      return _fromDio(error);
    }

    return UnknownFailure(error.toString());
  }

  static Failure _fromPlatform(PlatformException error) {
    final details = '${error.code} ${error.message ?? ''} ${error.details ?? ''}';
    if (error.code == 'sign_in_failed' || details.contains('ApiException: 10')) {
      return const AuthFailure(
        'Connexion Google non configurée pour cette app. Utilisez email ou téléphone.',
      );
    }
    if (error.code == 'network_error') {
      return const NetworkFailure();
    }
    return AuthFailure(error.message ?? 'Connexion Google impossible.');
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
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) {
        return message.map((item) => item.toString()).join('\n');
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      final nested = data['data'];
      if (nested is Map && nested['message'] is String) {
        return nested['message'] as String;
      }
    }
    return null;
  }
}
