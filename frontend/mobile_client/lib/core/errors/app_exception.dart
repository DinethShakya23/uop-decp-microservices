abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection or server unreachable.']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed. Please log in again.']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'You do not have permission to perform this action.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'An unexpected server error occurred.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'The requested resource was not found.']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Invalid input. Please check your data.']);
}

class ConflictException extends AppException {
  const ConflictException([super.message = 'A conflict occurred (e.g., username already exists).']);
}
