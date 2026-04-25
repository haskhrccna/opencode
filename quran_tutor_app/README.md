# Quran Tutor App

A Flutter application for Quran memorization tutoring with support for student, teacher, and admin roles.

## Phase 1 - Foundation Hardening

This phase establishes a solid architectural foundation for the application.

---

## 1. Environment Configuration

The app uses build-time configuration via dart defines to set API endpoints and environment settings.

### AppEnvironment Class

Located in `lib/core/environment/app_environment.dart`:

```dart
class AppEnvironment {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.qurantutor.app',
  );
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );
}
```

### Building with Different Environments

```bash
# Development (default)
flutter run

# With custom API
flutter run --dart-define=API_BASE_URL=https://api.example.com --dart-define=ENV=staging

# Production
flutter run --dart-define=API_BASE_URL=https://api.qurantutor.app --dart-define=ENV=prod --release

# Build APK with flavor
flutter build apk --dart-define=API_BASE_URL=https://api.qurantutor.app --dart-define=ENV=prod
```

### Environment Properties

| Property | dev | staging | prod |
|----------|-----|---------|------|
| baseUrl | dev-api.qurantutor.app | staging-api.qurantutor.app | api.qurantutor.app |
| enableDebugLogs | ✅ | ✅ | ❌ |
| enableAnalytics | ❌ | ❌ | ✅ |
| enableCrashReporting | ❌ | ✅ | ✅ |

---

## 2. Centralized Error Handling

All errors are now handled through a unified pipeline.

### Failure Hierarchy

Located in `lib/core/error/failures.dart`:

```
Failure (abstract)
├── NetworkFailure      # No connection, timeout
├── AuthFailure         # Login, signup, permissions
├── ServerFailure       # 4xx, 5xx HTTP errors
├── CacheFailure        # Local storage issues
├── ValidationFailure   # Form validation
├── BusinessFailure     # Business logic errors
└── UnknownFailure      # Unexpected errors
```

### Usage in UI

```dart
// Show error with retry
ErrorScreen(
  failure: NetworkFailure.noConnection(),
  onRetry: () => refetchData(),
);

// Check if error is retryable
if (failure.isRetryable) {
  showRetryButton();
}

// Get user-friendly message
Text(failure.userMessage);
```

### Firebase Exception Mapping

Located in `lib/core/error/firebase_exception_mapper.dart`:

Maps FirebaseAuthException codes to localized messages:

```dart
try {
  await auth.signInWithEmailAndPassword(...);
} on FirebaseAuthException catch (e) {
  final failure = FirebaseExceptionMapper.mapAuthException(e);
  // Display failure.message (already localized)
}
```

---

## 3. Logging Strategy

Located in `lib/core/utils/logging/app_logger.dart`:

### Debug Mode
- All log levels enabled
- Colorful output with emojis
- Method traces (2 for info, 8 for errors)
- BLoC state transitions
- Network requests/responses

### Release Mode
- Only warnings and errors logged
- No console colors or emojis
- Minimal stack traces
- Errors reported to crash analytics

```dart
final logger = AppLogger();

// Different log levels
logger.v('Verbose message');    // Only debug
logger.d('Debug message');      // Only debug
logger.i('Info message');       // Always
logger.w('Warning message');    // Always
logger.e('Error message');      // Always + crash report
logger.f('Fatal message');     // Always + crash report

// Context-specific logging
logger.logBlocEvent('AuthBloc', event);
logger.logRequest('GET', '/api/users');
logger.logResponse('GET', '/api/users', 200, data: response);
```

---

## 4. Password Validation

Updated regex in `lib/core/constants/app_constants.dart`:

### Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter  
- At least one number
- **Special characters are RECOMMENDED but optional**

### Regex
```dart
static final RegExp passwordRegex = RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
);
```

This allows passwords like:
- `Password123` ✅ (meets requirements)
- `Password123!` ✅ (with special char - stronger)
- `MyPass1` ✅ (minimum length met)
- `password123` ❌ (no uppercase)
- `PASSWORD123` ❌ (no lowercase)
- `Password` ❌ (no number)

---

## 5. Localization

Translation files located in `assets/lang/`:

### Supported Languages
- Arabic (ar) - Default
- English (en)

### Key Naming Convention
```
feature.context.message
├── app.name
├── auth.login.title
├── auth.validation.required
├── error.network
└── pending.title
```

### Usage

```dart
// In widgets
text: tr('auth.login.title')

// With parameters
text: tr('validation.required', args: {'field': 'Name'})

// Check locale
if (context.locale.languageCode == 'ar') ...
```

---

## 6. Theme Persistence

Located in `lib/core/theme/cubit/theme_cubit.dart`:

Theme state is persisted across app restarts using hydrated_bloc.

```dart
// Set specific theme
context.read<ThemeCubit>().setLight();
context.read<ThemeCubit>().setDark();
context.read<ThemeCubit>().setSystem();

// Toggle between light/dark
context.read<ThemeCubit>().toggle();

// Check current theme
final isDark = context.read<ThemeCubit>().state.isDark;
```

Theme is automatically restored on app launch from local storage.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # App-wide constants
│   ├── environment/
│   │   └── app_environment.dart       # Build-time config
│   ├── error/
│   │   ├── failures.dart              # Failure hierarchy
│   │   ├── exceptions.dart            # Data layer exceptions
│   │   ├── error_handler.dart         # Global error handling
│   │   └── firebase_exception_mapper.dart  # Firebase error mapping
│   ├── localization/
│   │   └── app_localizations.dart     # Localization service
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── cubit/
│   │       └── theme_cubit.dart       # Theme persistence
│   └── utils/
│       ├── bloc_observer.dart         # BLoC logging
│       ├── logging/
│       │   └── app_logger.dart        # Centralized logging
│       └── validators/
│           └── arabic_validators.dart
├── features/
│   ├── auth/
│   ├── admin/
│   ├── student/
│   ├── teacher/
│   ├── sessions/
│   ├── grading/
│   └── profile/
└── shared/
    └── widgets/
        └── error_screen.dart          # Reusable error screen
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0+
- Firebase project configured

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   # Development
   flutter run

   # With specific environment
   flutter run --dart-define=API_BASE_URL=https://dev-api.qurantutor.app
   ```

---

## Development Guidelines

### Error Handling
- Always catch exceptions in the data layer
- Convert exceptions to Failures before reaching the UI
- Use typed failures for specific error handling
- Never show raw exceptions to users

### Logging
- Use appropriate log levels
- Include context in log messages
- Don't log sensitive information (passwords, tokens)
- Use `kDebugMode` checks for debug-only logs

### Localization
- Add all new strings to both `en.json` and `ar.json`
- Use dot notation for nested keys
- Test in both RTL and LTR layouts
- Avoid hardcoded strings in widgets

### Environment Variables
- Never commit sensitive API keys
- Use different Firebase projects per environment
- Document new dart defines in this README

---

## Next Steps (Phase 2)

- Complete feature implementations
- Add comprehensive testing
- Implement push notifications
- Add offline support

---

## License

This project is proprietary and confidential.
