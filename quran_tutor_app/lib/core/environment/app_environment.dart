/// Environment configuration using build-time dart defines
///
/// Build with:
/// flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
///
/// Or use flutter flavors:
/// flutter run --flavor dev
/// flutter run --flavor staging
/// flutter run --flavor prod
class AppEnvironment {
  AppEnvironment._();

  /// Supabase URL - configurable at build time
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Supabase Anonymous Key - configurable at build time
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  /// OneSignal App ID for push notifications
  static const String oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: 'your-onesignal-app-id',
  );

  /// API Base URL - configurable at build time
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-project.supabase.co/rest/v1',
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
        return 'https://dev-your-project.supabase.co/rest/v1';
      case AppFlavor.staging:
        return 'https://staging-your-project.supabase.co/rest/v1';
      case AppFlavor.prod:
        return 'https://your-project.supabase.co/rest/v1';
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
