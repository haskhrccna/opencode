import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../environment/app_environment.dart';

/// Centralized logging utility with debug/release separation
/// 
/// In debug mode: logs everything to console with colors
/// In release mode: logs only errors/warnings, sends to Crashlytics
class AppLogger {
  static AppLogger? _instance;
  late final Logger _logger;

  /// Whether to enable detailed logging
  final bool _enableDetailedLogging;

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
        methodCount: kDebugMode ? 2 : 0,
        errorMethodCount: kDebugMode ? 8 : 0,
        lineLength: 120,
        colors: kDebugMode,
        printEmojis: kDebugMode,
        printTime: true,
      ),
      output: _LogOutput(),
    );

    // Set up Flutter error handling
    if (!kDebugMode && AppEnvironment.enableCrashReporting) {
      _setupCrashReporting();
    }
  }

  void _setupCrashReporting() {
    // Pass all uncaught errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Handle errors from Zones
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportToCrashlytics(
        'Platform Error',
        error,
        stack,
        fatal: false,
      );
      return true;
    };
  }

  /// Log verbose messages (only in debug mode)
  void v(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_shouldLog(kDebugMode)) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log debug messages (only in debug mode)
  void d(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_shouldLog(kDebugMode)) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info messages
  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_shouldLog(true)) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log warning messages
  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_shouldLog(true)) {
      _logger.w(message, error: error, stackTrace: stackTrace);
      
      // Report warnings to Crashlytics in production
      if (!kDebugMode && AppEnvironment.enableCrashReporting) {
        _reportToCrashlytics(message, error, stackTrace, fatal: false);
      }
    }
  }

  /// Log error messages
  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    if (_shouldLog(true)) {
      _logger.e(message, error: error, stackTrace: stackTrace);
      
      // Report errors to Crashlytics in production
      if (!kDebugMode && AppEnvironment.enableCrashReporting) {
        _reportToCrashlytics(message, error, stackTrace, fatal: false);
      }
    }
  }

  /// Log fatal messages - always reported to Crashlytics
  void f(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    
    // Always report fatal errors
    if (AppEnvironment.enableCrashReporting) {
      _reportToCrashlytics(message, error, stackTrace, fatal: true);
    }
  }

  /// Check if we should log based on level and environment
  bool _shouldLog(bool condition) {
    if (kDebugMode) return true;
    return condition && _enableDetailedLogging;
  }

  /// Report to Crashlytics
  void _reportToCrashlytics(
    String message,
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) {
    if (!AppEnvironment.enableCrashReporting) return;
    
    try {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: fatal,
      );
    } catch (e) {
      // If Crashlytics fails, at least log locally
      _logger.e('Failed to report to Crashlytics: $e');
    }
  }

  /// Log BLoC events (only in debug mode)
  void logBlocEvent(String blocName, dynamic event) {
    if (kDebugMode) {
      d('📤 [$blocName] Event: ${event.runtimeType}');
    }
  }

  /// Log BLoC state changes (only in debug mode)
  void logBlocState(String blocName, dynamic transition) {
    if (kDebugMode) {
      d('🔄 [$blocName] $transition');
    }
  }

  /// Log BLoC errors
  void logBlocError(String blocName, Object error, StackTrace stackTrace) {
    e('🔴 [$blocName] Error', error: error, stackTrace: stackTrace);
  }

  /// Log network requests (only in debug mode)
  void logRequest(String method, String url, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final dataStr = data != null ? ' | Data: $data' : '';
      i('⬆️ [$method] $url$dataStr');
    }
  }

  /// Log network responses (only in debug mode)
  void logResponse(String method, String url, int statusCode, {dynamic data}) {
    if (kDebugMode) {
      final dataStr = data != null ? ' | Body: $data' : '';
      final icon = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';
      i('$icon [$method] $url - Status: $statusCode$dataStr');
    }
  }

  /// Log navigation events (only in debug mode)
  void logNavigation(String from, String to) {
    if (kDebugMode) {
      i('🧭 Navigation: $from → $to');
    }
  }

  /// Close the logger
  void close() {
    _logger.close();
  }
}

/// Custom log filter that respects debug/release mode
class _LogFilter extends LogFilter {
  final bool _enableDetailedLogging;

  _LogFilter({required bool enableDetailedLogging})
      : _enableDetailedLogging = enableDetailedLogging;

  @override
  bool shouldLog(LogEvent event) {
    // In release mode, only log warnings and above
    if (!kDebugMode && event.level.index < Level.warning.index) {
      return false;
    }
    return _enableDetailedLogging;
  }
}

/// Custom log printer with environment-aware formatting
class _LogPrinter extends PrettyPrinter {
  _LogPrinter({
    required super.methodCount,
    required super.errorMethodCount,
    required super.lineLength,
    required super.colors,
    required super.printEmojis,
    required super.printTime,
  });

  @override
  List<String> log(LogEvent event) {
    // In release mode, strip emoji and color codes
    if (!kDebugMode) {
      final message = _formatMessage(event);
      return [message];
    }
    return super.log(event);
  }

  String _formatMessage(LogEvent event) {
    final time = DateTime.now().toIso8601String();
    final level = event.level.toString().split('.').last.toUpperCase();
    return '[$time] [$level] ${event.message}';
  }
}

/// Custom log output that can redirect to file in release mode
class _LogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    // In release mode, could redirect to file or crash reporting
    if (kDebugMode) {
      super.output(event);
    } else {
      // Only log errors and warnings in release
      if (event.level.index >= Level.warning.index) {
        super.output(event);
      }
    }
  }
}
