sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Erreur serveur.']);
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Connexion indisponible.']);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expirée.']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Erreur de stockage local.']);
}
