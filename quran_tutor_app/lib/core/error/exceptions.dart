/// Base class for all exceptions in the data layer
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => '[$runtimeType] $message';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'network_error',
          stackTrace: stackTrace,
        );

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection',
        code: 'no_connection',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Connection timed out',
        code: 'timeout',
      );

  factory NetworkException.unknown() => const NetworkException(
        message: 'Network error occurred',
        code: 'network_unknown',
      );
}

/// Server-related exceptions
class ServerException extends AppException {
  final int? statusCode;
  final dynamic responseData;

  const ServerException({
    required String message,
    String? code,
    this.statusCode,
    this.responseData,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'server_error',
          stackTrace: stackTrace,
        );

  factory ServerException.badRequest({dynamic responseData}) => ServerException(
        message: 'Bad request',
        code: 'bad_request',
        statusCode: 400,
        responseData: responseData,
      );

  factory ServerException.unauthorized() => const ServerException(
        message: 'Unauthorized',
        code: 'unauthorized',
        statusCode: 401,
      );

  factory ServerException.notFound() => const ServerException(
        message: 'Not found',
        code: 'not_found',
        statusCode: 404,
      );

  factory ServerException.internalError() => const ServerException(
        message: 'Internal server error',
        code: 'internal_error',
        statusCode: 500,
      );
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'cache_error',
          stackTrace: stackTrace,
        );

  factory CacheException.notFound() => const CacheException(
        message: 'Cache entry not found',
        code: 'cache_not_found',
      );

  factory CacheException.expired() => const CacheException(
        message: 'Cache entry expired',
        code: 'cache_expired',
      );
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'auth_error',
          stackTrace: stackTrace,
        );

  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid credentials',
        code: 'invalid_credentials',
      );

  factory AuthException.userNotFound() => const AuthException(
        message: 'User not found',
        code: 'user_not_found',
      );

  factory AuthException.emailAlreadyInUse() => const AuthException(
        message: 'Email already in use',
        code: 'email_already_in_use',
      );

  factory AuthException.weakPassword() => const AuthException(
        message: 'Weak password',
        code: 'weak_password',
      );

  factory AuthException.invalidEmail() => const AuthException(
        message: 'Invalid email',
        code: 'invalid_email',
      );

  factory AuthException.userDisabled() => const AuthException(
        message: 'User account disabled',
        code: 'user_disabled',
      );

  factory AuthException.sessionExpired() => const AuthException(
        message: 'Session expired',
        code: 'session_expired',
      );

  factory AuthException.unauthenticated() => const AuthException(
        message: 'User not authenticated',
        code: 'unauthenticated',
      );
}

/// Validation-related exceptions
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException({
    required String message,
    String? code,
    this.errors,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'validation_error',
          stackTrace: stackTrace,
        );

  factory ValidationException.invalidInput({String? message, Map<String, String>? errors}) =>
      ValidationException(
        message: message ?? 'Invalid input',
        code: 'invalid_input',
        errors: errors,
      );

  factory ValidationException.requiredField(String field) => ValidationException(
        message: '$field is required',
        code: 'required_field',
        errors: {field: 'This field is required'},
      );
}
