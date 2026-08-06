class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException() : super('Vérifiez votre connexion internet.');
}

class TimeoutException extends AppException {
  const TimeoutException() : super('La requête a expiré. Réessayez.');
}

class NotFoundException extends AppException {
  const NotFoundException()
      : super('Introuvable. Vérifiez les informations saisies.',
            statusCode: 404);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Session expirée, veuillez vous reconnecter.', statusCode: 401);
}

class ConflictException extends AppException {
  const ConflictException(String message) : super(message, statusCode: 409);
}

class ServerException extends AppException {
  const ServerException()
      : super('Erreur serveur. Réessayez plus tard.', statusCode: 500);
}
