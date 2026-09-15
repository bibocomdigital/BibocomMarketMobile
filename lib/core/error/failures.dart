sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Connexion indisponible.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur serveur.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentification requise.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de stockage local.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
