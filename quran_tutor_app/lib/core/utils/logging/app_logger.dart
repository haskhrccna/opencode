import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:quran_tutor_app/core/environment/app_environment.dart';

/// Centralized logging utility with debug/release separation
///
/// In debug mode: logs everything to console with colors
/// In release mode: logs only errors/warnings, sends to analytics
class AppLogger {
  factory AppLogger({bool enableDetailedLogging = true}) {
    _instance ??= AppLogger._internal(
      enableDetailedLogging: enableDetailedLogging,
    );
    return _instance!;
  }

  AppLogger._internal({required bool enableDetailedLogging})
      : _enableDetailedLogging = enableDetailedLogging {
    _logger = Logger(
      filter: _LogFilter(enableDetailedLogging: enableDetailedLogging),
      printer: _LogPrinter(
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: _LogOutput(),
    );
  }
  static AppLogger? _instance;
  late final Logger _logger;

  /// Whether to enable detailed logging
  final bool _enableDetailedLogging;

  /// Log a verbose/trace message
  void t(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableDetailedLogging) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a verbose message
  void v(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableDetailedLogging) {
      _logger.v(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a debug message
  void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableDetailedLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an info message
  void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // In production, could integrate with analytics here
    if (!kDebugMode && AppEnvironment.enableCrashReporting) {
      // TODO: Integrate with PostHog or other analytics
    }
  }

  /// Log a wtf message
  void wtf(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}

/// Custom log filter
class _LogFilter extends LogFilter {
  _LogFilter({required this.enableDetailedLogging});
  final bool enableDetailedLogging;

  @override
  bool shouldLog(LogEvent event) {
    if (!enableDetailedLogging) {
      // In production, only log warnings and above
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}

/// Custom log printer
class _LogPrinter extends PrettyPrinter {
  _LogPrinter({
    super.errorMethodCount,
    super.dateTimeFormat,
  });
}

/// Custom log output
class _LogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}
