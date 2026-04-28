import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// 
/// Failures represent expected error states that can occur
/// and should be handled gracefully by the UI
abstract class Failure extends Equatable {

  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures (no connection, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    String? code,
    super.stackTrace,
  }) : super(
          code: code ?? 'network_error',
        );

  factory NetworkFailure.noConnection() => const NetworkFailure(
        code: 'no_connection',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Connection timed out',
        code: 'timeout',
      );

  factory NetworkFailure.serverUnreachable() => const NetworkFailure(
        message: 'Server is unreachable',
        code: 'server_unreachable',
      );
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    String? code,
    super.stackTrace,
  }) : super(
          code: code ?? 'auth_error',
        );

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password',
        code: 'invalid_credentials',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'User not found',
        code: 'user_not_found',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'Email is already in use',
        code: 'email_already_in_use',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak',
        code: 'weak_password',
      );

  factory AuthFailure.invalidEmail() => const AuthFailure(
        message: 'Invalid email address',
        code: 'invalid_email',
      );

  factory AuthFailure.userDisabled() => const AuthFailure(
        message: 'Account has been disabled',
        code: 'user_disabled',
      );

  factory AuthFailure.unauthenticated() => const AuthFailure(
        message: 'Please sign in to continue',
        code: 'unauthenticated',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Session expired. Please sign in again',
        code: 'session_expired',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message: 'Too many requests. Please try again later',
        code: 'too_many_requests',
      );

  factory AuthFailure.operationNotAllowed() => const AuthFailure(
        message: 'Operation not allowed',
        code: 'operation_not_allowed',
      );

  factory AuthFailure.accountExistsWithDifferentCredential() =>
      const AuthFailure(
        message: 'Account exists with different credentials',
        code: 'account_exists_different_credential',
      );
}

/// Server-side failures (5xx errors, bad responses, etc.)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    String? code,
    super.stackTrace,
    this.statusCode,
  }) : super(
          code: code ?? 'server_error',
        );

  factory ServerFailure.badRequest({String? message}) => ServerFailure(
        message: message ?? 'Invalid request',
        code: 'bad_request',
        statusCode: 400,
      );

  factory ServerFailure.unauthorized() => const ServerFailure(
        message: 'Unauthorized access',
        code: 'unauthorized',
        statusCode: 401,
      );

  factory ServerFailure.forbidden() => const ServerFailure(
        message: 'Access forbidden',
        code: 'forbidden',
        statusCode: 403,
      );

  factory ServerFailure.notFound() => const ServerFailure(
        message: 'Resource not found',
        code: 'not_found',
        statusCode: 404,
      );

  factory ServerFailure.conflict() => const ServerFailure(
        message: 'Conflict occurred',
        code: 'conflict',
        statusCode: 409,
      );

  factory ServerFailure.internalError() => const ServerFailure(
        message: 'Internal server error',
        code: 'internal_error',
        statusCode: 500,
      );

  factory ServerFailure.serviceUnavailable() => const ServerFailure(
        message: 'Service temporarily unavailable',
        code: 'service_unavailable',
        statusCode: 503,
      );

  factory ServerFailure.gatewayTimeout() => const ServerFailure(
        message: 'Gateway timeout',
        code: 'gateway_timeout',
        statusCode: 504,
      );

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Cache-related failures (storage, retrieval, etc.)
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    String? code,
    super.stackTrace,
  }) : super(
          code: code ?? 'cache_error',
        );

  factory CacheFailure.writeError() => const CacheFailure(
        message: 'Failed to save data locally',
        code: 'cache_write_error',
      );

  factory CacheFailure.readError() => const CacheFailure(
        message: 'Failed to read data from local storage',
        code: 'cache_read_error',
      );

  factory CacheFailure.deleteError() => const CacheFailure(
        message: 'Failed to delete local data',
        code: 'cache_delete_error',
      );

  factory CacheFailure.clearError() => const CacheFailure(
        message: 'Failed to clear local storage',
        code: 'cache_clear_error',
      );

  factory CacheFailure.dataExpired() => const CacheFailure(
        message: 'Cached data has expired',
        code: 'cache_expired',
      );

  factory CacheFailure.keyNotFound() => const CacheFailure(
        message: 'Data not found in local storage',
        code: 'cache_key_not_found',
      );
}

/// Validation failures (form validation, business logic, etc.)
class ValidationFailure extends Failure {

  const ValidationFailure({
    required super.message,
    String? code,
    this.fieldErrors,
    super.stackTrace,
  }) : super(
          code: code ?? 'validation_error',
        );

  factory ValidationFailure.invalidInput({String? message}) => ValidationFailure(
        message: message ?? 'Invalid input',
        code: 'invalid_input',
      );

  factory ValidationFailure.requiredField({required String fieldName}) =>
      ValidationFailure(
        message: '$fieldName is required',
        code: 'required_field',
        fieldErrors: {fieldName: 'This field is required'},
      );

  factory ValidationFailure.invalidFormat({required String fieldName}) =>
      ValidationFailure(
        message: '$fieldName has invalid format',
        code: 'invalid_format',
        fieldErrors: {fieldName: 'Invalid format'},
      );
  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Business logic failures
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    String? code,
    super.stackTrace,
  }) : super(
          code: code ?? 'business_error',
        );

  factory BusinessFailure.operationNotAllowed() => const BusinessFailure(
        message: 'This operation is not allowed',
        code: 'operation_not_allowed',
      );

  factory BusinessFailure.insufficientPermissions() => const BusinessFailure(
        message: 'Insufficient permissions for this operation',
        code: 'insufficient_permissions',
      );

  factory BusinessFailure.resourceNotAvailable() => const BusinessFailure(
        message: 'Resource is not available',
        code: 'resource_not_available',
      );

  factory BusinessFailure.invalidState() => const BusinessFailure(
        message: 'Invalid state for this operation',
        code: 'invalid_state',
      );
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    String? code,
    super.stackTrace,
  }) : super(
          code: code ?? 'unknown_error',
        );
}

/// Extension methods for Failure handling
extension FailureX on Failure {
  /// Check if this is a critical failure that should be reported
  bool get isCritical => this is ServerFailure || this is UnknownFailure;

  /// Check if the user can retry this operation
  bool get isRetryable =>
      this is NetworkFailure ||
      this is ServerFailure ||
      (this is AuthFailure && code == 'session_expired');

  /// Get user-friendly error message
  String get userMessage {
    if (this is NetworkFailure) {
      return 'Please check your internet connection and try again';
    }
    if (this is ServerFailure) {
      return 'Something went wrong on our end. Please try again later';
    }
    if (this is AuthFailure) {
      return message;
    }
    if (this is CacheFailure) {
      return 'There was a problem accessing your data';
    }
    return 'An unexpected error occurred. Please try again';
  }
}
