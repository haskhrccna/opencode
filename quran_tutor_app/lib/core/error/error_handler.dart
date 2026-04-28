import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran_tutor_app/core/error/failures.dart';
import 'package:quran_tutor_app/core/utils/logging/app_logger.dart';

/// Centralized error handler for the application
///
/// This class handles all application-level errors including:
/// - Flutter framework errors
/// - Platform dispatcher errors
/// - Uncaught async errors
/// - Error reporting and logging
class ErrorHandler {
  ErrorHandler._();

  static final _logger = AppLogger();

  /// Initialize error handling
  static void initialize() {
    // Capture Flutter framework errors
    FlutterError.onError = _handleFlutterError;

    // Capture platform dispatcher errors (isolate-level errors)
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // Set up zone error handling for async errors
    _setupZoneErrorHandling();
  }

  /// Handle Flutter framework errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    final failure = _convertFlutterErrorToFailure(details);

    _logger.e(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );

    if (kDebugMode) {
      // In debug mode, show the error in the console
      FlutterError.presentError(details);
    } else {
      // In release mode, log and potentially report to crash analytics
      _reportError(failure);
    }
  }

  /// Handle platform dispatcher errors (from isolates)
  static bool _handlePlatformError(Object error, StackTrace stack) {
    final failure = _convertToFailure(error, stack);

    _logger.e(
      'Platform Error: $error',
      error: error,
      stackTrace: stack,
    );

    _reportError(failure);
    return true; // Error is handled
  }

  /// Set up zone error handling
  static void _setupZoneErrorHandling() {
    // This is done in main.dart by wrapping runApp with runZonedGuarded
  }

  /// Convert Flutter error to Failure
  static Failure _convertFlutterErrorToFailure(FlutterErrorDetails details) {
    final exception = details.exception;

    if (exception is Exception) {
      return _convertExceptionToFailure(exception, details.stack);
    }

    return UnknownFailure(
      message: exception.toString(),
      stackTrace: details.stack,
    );
  }

  /// Convert any error to Failure
  static Failure _convertToFailure(Object error, StackTrace? stack) {
    if (error is Exception) {
      return _convertExceptionToFailure(error, stack);
    }

    return UnknownFailure(
      message: error.toString(),
      stackTrace: stack,
    );
  }

  /// Convert exceptions to Failures
  static Failure _convertExceptionToFailure(Exception exception, StackTrace? stack) {
    if (exception is SocketException) {
      return NetworkFailure.noConnection();
    }

    if (exception is TimeoutException) {
      return NetworkFailure.timeout();
    }

    if (exception is FormatException) {
      return ServerFailure.badRequest(
        message: 'Invalid data format received from server',
      );
    }

    return UnknownFailure(
      message: exception.toString(),
      stackTrace: stack,
    );
  }

  /// Report error to crash analytics
  static void _reportError(Failure failure) {
    // TODO: Integrate with analytics service
    if (!kDebugMode) {
      // Could send to PostHog or other analytics
    }
  }

  /// Handle errors in async operations
  static Future<T> handleAsync<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } catch (error, stack) {
      final failure = _convertToFailure(error, stack);
      _logger.e(
        'Async operation failed: ${operationName ?? "Unknown"}',
        error: error,
        stackTrace: stack,
      );
      throw failure;
    }
  }

  /// Wrap a widget with error boundary
  static Widget wrapWithErrorBoundary({
    required Widget child,
    required Widget Function(Failure failure) errorBuilder,
  }) {
    return _ErrorBoundary(
      errorBuilder: errorBuilder,
      child: child,
    );
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(failure)),
        content: Text(failure.userMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null && failure.isRetryable)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Get error title based on failure type
  static String _getErrorTitle(Failure failure) {
    if (failure is NetworkFailure) return 'Connection Error';
    if (failure is AuthFailure) return 'Authentication Error';
    if (failure is ServerFailure) return 'Server Error';
    if (failure is CacheFailure) return 'Storage Error';
    return 'Error';
  }
}

/// Error boundary widget
class _ErrorBoundary extends StatefulWidget {

  const _ErrorBoundary({
    required this.child,
    required this.errorBuilder,
  });
  final Widget child;
  final Widget Function(Failure failure) errorBuilder;

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (details) {
      return widget.errorBuilder(
        UnknownFailure(
          message: details.exception.toString(),
          stackTrace: details.stack,
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_failure != null) {
      return widget.errorBuilder(_failure!);
    }
    return widget.child;
  }
}
