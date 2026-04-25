/// Environment configuration using build-time dart defines
/// 
/// Build with:
/// flutter run --dart-define=API_BASE_URL=https://api.qurantutor.app --dart-define=ENV=prod
/// 
/// Or use flutter flavors:
/// flutter run --flavor dev
/// flutter run --flavor staging
/// flutter run --flavor prod
class AppEnvironment {
  AppEnvironment._();

  /// API Base URL - configurable at build time
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.qurantutor.app',
  );

  /// Environment name (dev, staging, prod)
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// API Timeout values
  static const int apiTimeout = 30000; // milliseconds
  static const int apiReceiveTimeout = 30000;

  /// Check if running in development mode
  static bool get isDev => env == 'dev';

  /// Check if running in staging mode
  static bool get isStaging => env == 'staging';

  /// Check if running in production mode
  static bool get isProd => env == 'prod';

  /// Check if debug logging should be enabled
  static bool get enableDebugLogs => isDev || isStaging;

  /// Check if analytics should be enabled
  static bool get enableAnalytics => isProd;

  /// Check if crash reporting should be enabled
  static bool get enableCrashReporting => isProd || isStaging;

  /// Get environment display name
  static String get displayName {
    switch (env) {
      case 'prod':
        return 'Production';
      case 'staging':
        return 'Staging';
      case 'dev':
      default:
        return 'Development';
    }
  }

  /// Get API base URL for current environment
  static String get apiBaseUrl => baseUrl;
}

/// Flavor-specific configurations
enum AppFlavor {
  dev,
  staging,
  prod;

  String get baseUrl {
    switch (this) {
      case AppFlavor.dev:
        return 'https://dev-api.qurantutor.app';
      case AppFlavor.staging:
        return 'https://staging-api.qurantutor.app';
      case AppFlavor.prod:
        return 'https://api.qurantutor.app';
    }
  }

  String get displayName {
    switch (this) {
      case AppFlavor.dev:
        return 'Development';
      case AppFlavor.staging:
        return 'Staging';
      case AppFlavor.prod:
        return 'Production';
    }
  }

  bool get enableDebugLogs => this != AppFlavor.prod;
  bool get enableAnalytics => this == AppFlavor.prod;
}
