# Quran Tutor App — Agent Guide

This file contains everything an AI coding agent needs to know to work effectively on the Quran Tutor App project. All information below is derived from the actual project source code, configuration files, and documentation.

---

## Project Overview

**Quran Tutor App** is a cross-platform Flutter application for Quran memorization tutoring. It supports three user roles with distinct capabilities:

- **Student** — views sessions, tracks memorization progress, receives grades
- **Teacher** — manages students, schedules sessions, records Tajweed feedback, assigns grades
- **Admin** — approves/rejects registrations, manages teachers, views reports, configures system settings

The app is RTL-first (Arabic is the default locale) with full English fallback. It targets Android and iOS.

**Current status:** Foundation, authentication, domain layer, security hardening, and CI/CD scaffolding are complete. Data layer implementations and full presentation layer UIs are in progress.

---

## Technology Stack

| Layer | Package | Purpose |
|-------|---------|---------|
| Framework | Flutter SDK `>=3.0.0 <4.0.0` | UI framework |
| State Management | `flutter_bloc` ^9.1.1 | BLoC pattern with Cubits |
| State Persistence | `hydrated_bloc` ^11.0.0 | Persist BLoC state across restarts (theme, etc.) |
| Navigation | `go_router` ^17.2.2 | Declarative routing with deep links |
| Backend | `supabase_flutter` ^2.9.0 | Primary backend (Auth, PostgREST, Realtime, Storage) |
| Push Notifications | `onesignal_flutter` ^5.2.5 | Cross-platform push notifications |
| Local DB | `drift` ^2.15.0 + `sqlite3_flutter_libs` | Offline SQLite ORM |
| Dependency Injection | `get_it` ^9.2.1 + `injectable` ^3.0.0 | Service locator with code generation |
| HTTP | `dio` ^5.4.0 | HTTP client (legacy/secondary) |
| Forms | `flutter_form_builder` ^10.3.0 + `form_builder_validators` ^11.3.0 | Declarative forms |
| Localization | `easy_localization` ^3.0.3 + `intl` ^0.20.2 | Runtime localization |
| Calendar | `table_calendar` ^3.0.9 | Session scheduling UI |
| Charts | `fl_chart` ^1.2.0 | Progress visualization |
| PDF | `pdf` ^3.10.4 + `printing` ^5.11.1 | Report export |
| Audio | `just_audio` ^0.10.5 + `record` ^6.2.0 + `audio_session` ^0.2.3 | Tajweed recording and playback |
| Images | `image_picker` ^1.0.7 + `cached_network_image` ^3.3.1 | Avatar upload and caching |
| Local Notifications | `flutter_local_notifications` ^21.0.0 | Reminder notifications |
| Secure Storage | `flutter_secure_storage` ^10.0.0 | Token and sensitive data storage |
| Connectivity | `connectivity_plus` ^6.1.5 + `internet_connection_checker` ^3.0.1 | Network state monitoring |
| Analytics | `posthog_flutter` ^5.24.0 | Lightweight analytics (production only) |
| Utilities | `uuid`, `logger`, `package_info_plus`, `device_info_plus`, `share_plus`, `url_launcher` | Various helpers |

**Dev dependencies:**
- `flutter_test`, `integration_test` — Testing frameworks
- `bloc_test` ^10.0.0 — BLoC testing utilities
- `mocktail` ^1.0.4 — Mocking (the project **only** uses `mocktail`; `mockito` was removed)
- `build_runner` ^2.4.8 — Code generation
- `injectable_generator` ^3.0.2 — DI code generation
- `flutter_lints` ^6.0.0 + `very_good_analysis` ^10.2.0 — Linting

---

## Project Structure

The project follows **Clean Architecture** with a **feature-based** module division inside `lib/`.

```
lib/
├── main.dart                          # App entry point
├── core/                              # Shared core infrastructure
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants, enums (UserRole, UserStatus, SessionStatus, etc.)
│   ├── environment/
│   │   └── app_environment.dart       # Build-time environment configuration (dart defines)
│   ├── error/
│   │   ├── failures.dart              # Failure hierarchy (Network, Auth, Server, Cache, Validation, Business, Unknown)
│   │   ├── exceptions.dart            # Data-layer exceptions
│   │   ├── error_handler.dart         # Global error handling, FlutterError.onError, PlatformDispatcher.onError
│   │   └── firebase_exception_mapper.dart  # Firebase exception to Failure mapping
│   ├── localization/
│   │   └── app_localizations.dart     # Localization service helpers
│   ├── router/
│   │   └── app_router.dart            # go_router configuration with role-based redirects
│   ├── services/
│   │   ├── audio/                     # Audio playback service
│   │   ├── dependency_injection/
│   │   │   ├── injection.dart         # get_it + injectable setup
│   │   │   └── injection.config.dart  # Generated DI configuration
│   │   ├── notifications/             # Local notification service
│   │   ├── offline/                   # Drift database and offline sync service
│   │   ├── pdf/                       # PDF generation service
│   │   └── realtime/                  # Supabase realtime service
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_theme.dart             # Light/dark ThemeData with Material 3
│   │   └── cubit/
│   │       └── theme_cubit.dart       # Theme switching with hydrated_bloc persistence
│   └── utils/
│       ├── bloc_observer.dart         # AppBlocObserver (debug-only verbose logging)
│       ├── extensions/
│       │   └── date_extensions.dart   # Date/time helpers
│       ├── logging/
│       │   └── app_logger.dart        # Centralized logging (debug/release aware)
│       ├── pagination.dart            # Cursor pagination helper
│       ├── sanitizer.dart             # Input sanitization (XSS prevention, control chars)
│       └── validators/
│           └── arabic_validators.dart # Arabic-specific form validators
├── features/                          # Feature modules (Clean Architecture layers)
│   ├── auth/                          # Authentication
│   │   ├── data/datasources/          # AuthRemoteDataSource, AuthLocalDataSource
│   │   ├── data/models/               # UserModel
│   │   ├── data/repositories/         # AuthRepositoryImpl
│   │   ├── domain/entities/           # AuthUser
│   │   ├── domain/repositories/       # AuthRepository interface
│   │   ├── domain/usecases/           # SignIn, SignUpStudent, SignUpTeacher, SignOut, GetCurrentUser, ResetPassword
│   │   └── presentation/              # AuthBloc, screens (Splash, Login, Signup, PendingApproval, Rejected), widgets
│   ├── admin/                         # Admin dashboard and management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/              # AdminDashboard, PendingStudents, TeacherManagement, Sessions, Reports, Settings
│   ├── student/                       # Student-specific UI
│   │   └── presentation/screens/      # StudentHomeScreen
│   ├── teacher/                       # Teacher-specific UI
│   │   └── presentation/screens/      # TeacherHomeScreen, TeacherSessionsScreen, TeacherStudentsScreen
│   ├── sessions/                      # Session scheduling and management
│   │   ├── data/
│   │   ├── domain/entities/           # Session
│   │   └── presentation/              # SessionsScreen, SessionDetailScreen
│   ├── grading/                       # Progress grading and reports
│   │   ├── data/
│   │   ├── domain/entities/           # ProgressGrade
│   │   └── presentation/              # ProgressScreen
│   └── profile/                       # User profile management
│       ├── data/
│       ├── domain/
│       └── presentation/              # ProfileScreen
└── shared/                            # Shared UI components and models
    ├── models/
    ├── presentation/screens/
    └── widgets/
        └── error_screen.dart          # Reusable error display widget

test/
├── features/
│   ├── admin/presentation/screens/
│   ├── auth/
│   │   ├── data/datasources/
│   │   ├── data/repositories/
│   │   ├── domain/usecases/
│   │   └── presentation/
│   ├── sessions/data/datasources/
│   └── student/presentation/screens/
├── integration_test/
│   └── auth_flow_test.dart            # End-to-end auth flow tests
└── widget_test.dart

assets/
├── lang/
│   ├── ar.json                        # Arabic translations (default)
│   └── en.json                        # English translations
├── images/                            # Image assets (currently empty, .gitkeep)
├── icons/                             # Icon assets (currently empty, .gitkeep)
├── fonts/                             # Custom fonts (Cairo font family)
└── quran/                             # Quran text/assets

supabase/
└── functions/
    └── send-notification/index.ts     # Supabase Edge Function for OneSignal push notifications

docs/
├── LOCALIZATION_GUIDE.md
├── PHASE2_5_EXIT_CRITERIA.md
├── PHASE3_PROGRESS.md
└── PROJECT_SUMMARY.md                 # Detailed project phase documentation
```

**Key conventions:**
- Every feature follows the layers: `data` → `domain` → `presentation`
- `data` contains datasources, models, and repository implementations
- `domain` contains entities, repository interfaces, and use cases
- `presentation` contains BLoCs/Cubits, screens, and widgets
- The `core/` directory is for cross-cutting concerns only
- `shared/` is for reusable UI widgets that don't belong to a specific feature

---

## Build & Run Commands

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK compatible with Flutter version
- Android SDK / Xcode for mobile builds

### Install dependencies
```bash
flutter pub get
```

### Run code generation (required after changing injectable-annotated classes)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run the app (Development)
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=API_BASE_URL=https://dev-api.qurantutor.app \
  --dart-define=ENV=dev
```

### Run the app (Production)
```bash
flutter run --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=API_BASE_URL=https://api.qurantutor.app \
  --dart-define=ENV=prod
```

### Build APK
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=ENV=prod
```

### Build iOS
```bash
flutter build ios --release
```

### Run tests
```bash
# Unit and widget tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/auth_flow_test.dart
```

### Analyze code
```bash
flutter analyze
```

---

## Environment Configuration

The app uses **build-time `dart-define`** for all environment-specific values. **No runtime `.env` file is loaded by the app.** The `.env` file in the repository root exists for reference but is NOT used by `main.dart`.

**Required dart defines:**
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_ANON_KEY` — Supabase anonymous/public key
- `API_BASE_URL` — REST API base URL (defaults to Supabase REST endpoint)
- `ENV` — Environment name: `dev`, `staging`, or `prod`
- `ONESIGNAL_APP_ID` — OneSignal app ID for push notifications

**Environment behavior** (from `lib/core/environment/app_environment.dart`):

| Property | dev | staging | prod |
|----------|-----|---------|------|
| `enableDebugLogs` | ✅ | ✅ | ❌ |
| `enableAnalytics` | ❌ | ❌ | ✅ |
| `enableCrashReporting` | ❌ | ✅ | ✅ |

In `main.dart`, `SUPABASE_URL` and `SUPABASE_ANON_KEY` are asserted as non-empty at startup. The app will crash on launch if they are not provided.

---

## Architecture & Code Organization

### Clean Architecture Flow
```
Presentation (BLoC/Screen)
    ↓
Domain (Use Case)
    ↓
Domain (Repository Interface)
    ↓
Data (Repository Implementation)
    ↓
Data (DataSource — Remote/Local)
```

### Dependency Injection
- Uses `get_it` with `injectable` annotations
- `configureDependencies()` is called in `main.dart` before `runApp()`
- `SupabaseModule` provides singletons for Supabase sub-clients (`supabaseClient`, `auth`, `database`, `storage`, `realtime`)
- After adding or modifying `@injectable`, `@singleton`, or `@module` annotations, run `build_runner`

### Routing
- `go_router` is configured in `lib/core/router/app_router.dart`
- Routes are role-protected via `_redirect()` which reads `AuthBloc` state
- Deep links supported: `/invite/:code`, `/session/:id`
- `authRefreshNotifier` (ValueNotifier) triggers route re-evaluation when auth state changes

### Auth Flow & Role-Based Access Control
1. App starts → `SplashScreen` → `AuthBloc` checks current user
2. Unauthenticated → redirected to `/auth/login`
3. Authenticated + pending approval → `/pending-approval` (auto-refreshes every 30s)
4. Authenticated + rejected → `/rejected`
5. Authenticated + approved → role-based home (`/student/home`, `/teacher/home`, `/admin/dashboard`)
6. Route guards prevent cross-role navigation

---

## State Management

- **Primary pattern:** BLoC (via `flutter_bloc`)
- **State persistence:** `hydrated_bloc` for `ThemeCubit` (saves theme mode to disk)
- **BLoC observation:** `AppBlocObserver` logs create/event/change/transition/close in debug mode only. Errors are always logged.
- Every feature presentation layer has its own BLoC/Cubit with dedicated `Event` and `State` classes.

---

## Error Handling & Logging

### Failure Hierarchy (`lib/core/error/failures.dart`)
All errors in the domain/presentation layer are represented as `Failure` subclasses:
- `NetworkFailure` — no connection, timeout, server unreachable
- `AuthFailure` — invalid credentials, user not found, session expired, etc.
- `ServerFailure` — HTTP errors with status codes (400, 401, 403, 404, 500, etc.)
- `CacheFailure` — local storage read/write/delete errors
- `ValidationFailure` — form/business validation with optional `fieldErrors` map
- `BusinessFailure` — operation not allowed, insufficient permissions
- `UnknownFailure` — catch-all for unexpected errors

**Rules:**
- Data layer catches exceptions and converts them to Failures
- Presentation layer never receives raw exceptions
- UI displays `failure.userMessage` (localized-friendly)
- Use `failure.isRetryable` to show/hide retry buttons

### Logging (`lib/core/utils/logging/app_logger.dart`)
- Singleton `AppLogger` wraps the `logger` package
- Debug mode: all levels (trace, debug, info, warning, error, wtf)
- Release mode: only warning and above
- Crash reporting integration point exists but is marked `TODO` for PostHog
- **Never log sensitive data** (passwords, tokens, PII)

### Global Error Handler (`lib/core/error/error_handler.dart`)
- Sets `FlutterError.onError` and `PlatformDispatcher.instance.onError`
- Converts framework/platform errors to `Failure` objects
- Provides `ErrorHandler.handleAsync()` wrapper for async operations
- Provides `ErrorHandler.showErrorDialog()` for consistent error UI

---

## Localization

- **Default locale:** Arabic (`ar`)
- **Supported locales:** Arabic (`ar`), English (`en`)
- **Fallback:** Arabic
- Translation files: `assets/lang/ar.json`, `assets/lang/en.json`
- Uses `easy_localization` with `context.tr()` and `context.locale`

### Key naming convention
```
feature.context.message
```
Examples:
- `auth.login.title`
- `auth.validation.required`
- `error.network`

### Guidelines
- All user-facing strings MUST be in both `ar.json` and `en.json`
- Use dot notation for nested keys
- Test UI changes in both RTL and LTR layouts
- Never hardcode strings in widgets

---

## Testing Strategy

### Test Types Present
1. **Unit tests** — Domain use cases, repository implementations
2. **BLoC tests** — Using `bloc_test` package with `Mock` from `mocktail`
3. **Widget tests** — Screen rendering and interaction
4. **Integration tests** — Full auth flow (Splash → Login → Home, bad credentials, registration → pending)

### Testing Conventions
- Mocking is done with `mocktail` only. `mockito` was intentionally removed.
- BLoC tests verify state sequences using `blocTest()`
- Repository tests mock datasources
- The project has a coverage target of **80%+** for domain and data layers, **80%+** for BLoCs

### Running tests
```bash
flutter test                    # All unit/widget tests
flutter test --coverage         # With coverage report
flutter test integration_test/  # Integration tests
```

### Current test file locations
- `test/features/auth/` — Auth use cases, repository, BLoC, screens
- `test/features/admin/presentation/screens/` — Admin dashboard widget test
- `test/features/sessions/data/datasources/` — Sessions remote datasource test
- `test/features/student/presentation/screens/` — Student home widget test
- `integration_test/auth_flow_test.dart` — End-to-end golden path and error flows

---

## Code Style & Linting

- Lint rules: `package:very_good_analysis/analysis_options.yaml`
- Excluded from analysis: `**/*.g.dart`, `**/*.freezed.dart`, `**/injection.config.dart`

### Style Guidelines
- Use `const` constructors wherever possible
- Prefer single quotes for strings
- Follow the existing feature-based folder structure for new features
- Match existing naming: `*_screen.dart` for pages, `*_bloc.dart` for BLoCs, `*_cubit.dart` for Cubits, `*_event.dart`, `*_state.dart`
- Use `Equatable` for all BLoC states and events
- Keep UI strings out of widgets; use localization keys

---

## Security Considerations

### Input Sanitization (`lib/core/utils/sanitizer.dart`)
- Strip control characters
- Remove HTML tags (XSS prevention)
- Validate email, phone (Saudi format `+9665XXXXXXXX` or `05XXXXXXXX`), and name formats
- Enforce length limits

### Authentication
- Password requirements: min 8 chars, at least one uppercase, one lowercase, one number. Special characters are **recommended but optional**.
- Regex: `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$`
- Secure token storage via `flutter_secure_storage`

### Environment Secrets
- **Never commit API keys or secrets.** The `.env` file is in `.gitignore`.
- Supabase credentials must be passed via `--dart-define` at build time.
- The repository contains a `.env` file with placeholder/real values; do not treat it as a source of truth for CI.

### Firestore Rules Reference
The project documentation mentions Firestore security rules (from an earlier Firebase iteration). The current backend is Supabase, so Row Level Security (RLS) policies should be configured in Supabase instead.

---

## Asset Management

Registered asset directories in `pubspec.yaml`:
- `assets/lang/` — Translation JSON files
- `assets/images/` — Image assets (empty currently)
- `assets/icons/` — Icon assets (empty currently)
- `assets/fonts/` — Custom fonts (Cairo family is the primary font)
- `assets/quran/` — Quran-related static assets

**Font:** The app uses the **Cairo** font family defined in `AppTheme`.

---

## Backend & Services

### Supabase
- Primary backend for authentication, database, storage, and realtime subscriptions
- Tables referenced in code: `users`, `teachers`, `students`, `sessions`, `grades`, `admin_notifications`, `teacher_invites`, `notifications`, `audit_logs`
- Supabase Edge Function: `send-notification` (`supabase/functions/send-notification/index.ts`) — proxies push notifications to OneSignal REST API

### OneSignal
- Push notification delivery
- Configured via `onesignal_flutter` SDK
- App ID passed via `ONESIGNAL_APP_ID` dart define

### PostHog
- Analytics integration (`posthog_flutter`)
- Enabled only in production builds (`AppEnvironment.enableAnalytics`)

---

## Development Workflow

### Before committing
1. Run `flutter analyze` — must pass with zero issues
2. Run `flutter test` — all tests must pass
3. Run `flutter pub run build_runner build` if DI annotations changed
4. Verify localization keys exist in both `ar.json` and `en.json`

### Adding a new feature
1. Create the feature folder under `lib/features/<feature_name>/`
2. Add the three layers: `data/`, `domain/`, `presentation/`
3. Define entities, repository interface, and use cases in `domain/`
4. Implement datasources and repository in `data/`
5. Create BLoC, screens, and widgets in `presentation/`
6. Add routes to `lib/core/router/app_router.dart`
7. Register dependencies with `@injectable` in the new classes
8. Run `build_runner` to regenerate `injection.config.dart`
9. Add unit/BLoC/widget tests under `test/features/<feature_name>/`
10. Add localization keys to both language files

### CI/CD
- The `.github/workflows/` directory exists but is **currently empty**. No active CI pipelines are configured.
- The project documentation mentions a planned CI workflow with `flutter analyze`, `flutter test --coverage`, and build artifact generation, but it has not been implemented yet.

---

## Important Notes for Agents

- **Do not use `mockito`.** The project standardized on `mocktail`. If you need mocks, extend `Mock` from `mocktail`.
- **Do not add `syncfusion_flutter_charts`.** It was removed due to licensing concerns. Use `fl_chart` for all charts.
- **Do not hardcode strings.** Always add them to `ar.json` and `en.json`.
- **Avoid `path_provider` duplicates.** It is already declared.
- **ThemeMode.system** uses the system brightness; do not override this behavior.
- **BLoC logs are stripped in release.** Never remove the `kDebugMode` guards in `AppBlocObserver`.
- **Password regex:** Do not re-add mandatory special character requirements. The current regex allows passwords without special characters.
- **Supabase is the primary backend.** Firebase references in older documentation are historical; the active code uses `supabase_flutter`.
- **Main language of comments and documentation is English.** Code should be written in English with Arabic reserved for user-facing strings and localization files.
