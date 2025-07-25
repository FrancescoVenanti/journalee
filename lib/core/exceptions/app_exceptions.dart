abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class AppAuthException extends AppException {
  const AppAuthException(String message, [String? code]) : super(message, code);
}

class RepositoryException extends AppException {
  const RepositoryException(String message, [String? code])
      : super(message, code);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(String message, this.fieldErrors, [String? code])
      : super(message, code);
}

class NetworkException extends AppException {
  const NetworkException(String message, [String? code]) : super(message, code);
}

class StorageException extends AppException {
  const StorageException(String message, [String? code]) : super(message, code);
}

class PermissionException extends AppException {
  const PermissionException(String message, [String? code])
      : super(message, code);
}

class NotificationException extends AppException {
  const NotificationException(String message, [String? code])
      : super(message, code);
}
