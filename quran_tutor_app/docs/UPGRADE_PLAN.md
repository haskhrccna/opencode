# Quran Tutor App — Comprehensive Upgrade Plan

**Generated:** 2026-04-28  
**Current Status:** Phase 3 Domain Layer Complete → Data & Presentation Layers In Progress  
**Target:** Production-Ready Application with Full Feature Parity Across All Roles

---

## Executive Summary

The Quran Tutor App has a **world-class architectural foundation** — Clean Architecture, comprehensive auth with tests, well-designed domain layers, and a robust core infrastructure. However, **the gap between domain design and user-facing functionality is significant**. Most repositories are stubs, many screens are placeholders, tests are failing, and critical bugs exist in core utilities.

This plan provides a **prioritized, phase-by-phase roadmap** to bridge that gap. It is organized by urgency, not by feature, to ensure maximum impact per engineering hour.

---

## Phase 1: Critical Fixes & Stabilization 🚨
*Goal: Fix all failing tests, resolve critical bugs, and make the codebase stable.*  
*Estimated Effort: 2–3 days*

### 1.1 Fix All Failing Tests (16 failures)

| File | Failures | Root Cause | Fix Strategy |
|------|----------|------------|--------------|
| `auth_repository_impl_test.dart` | 5 | Repository wraps exceptions in `UnknownFailure` instead of typed failures | **Option A (Recommended):** Fix `AuthRepositoryImpl` to return proper typed failures (`AuthFailure`, `ValidationFailure`, `NetworkFailure`). **Option B:** Update tests to match current `UnknownFailure` behavior (less desirable). |
| `student_home_screen_test.dart` | 4 | Missing `registerFallbackValue(FakeAuthEvent())` for mocktail | Add `registerFallbackValue(FakeAuthEvent())` in `setUpAll` |
| `admin_dashboard_screen_test.dart` | 5 | Missing `registerFallbackValue(FakeAdminEvent())` for mocktail | Add `registerFallbackValue(FakeAdminEvent())` in `setUpAll` |
| `login_screen_test.dart` | 2 | Overly broad `find.textContaining()` matchers | Use specific localization key text or `find.text()` with exact error messages |

**Action Items:**
- [ ] Fix `AuthRepositoryImpl` exception-to-failure mapping to return typed failures
- [ ] Add `FakeAuthEvent` and `FakeAdminEvent` fallback values in respective test files
- [ ] Fix login screen test matchers to be precise
- [ ] Run `flutter test` and verify **0 failures**

### 1.2 Fix Critical Core Bugs

| Bug | Location | Impact | Fix |
|-----|----------|--------|-----|
| **Raw string literal in localization** | `lib/core/localization/app_localizations.dart:25` | Custom `AppLocalizations` cannot load translation files | Remove `r` prefix from string: `'${AppConstants.translationsPath}/${locale.languageCode}.json'` |
| **Realtime subscription leak** | `lib/core/services/realtime/realtime_service.dart` | `_clearSessionSubscriptions()` cancels ALL subscriptions, not just session ones | Maintain separate subscription lists per channel type, or filter by prefix before cancelling |
| **Shadow `Failure` class** | `lib/core/utils/pagination.dart` | Conflicts with `core/error/failures.dart`, causes import ambiguity | Rename to `PaginationFailure` or remove and reuse core `Failure` hierarchy |
| **Missing route** | `lib/core/router/app_router.dart` | `TeacherSignupScreen` exists but is unreachable via navigation | Add route entry for `/auth/teacher-signup` or integrate into signup flow |

### 1.3 Fix Dependency Configuration

- [ ] Move `bloc_test` and `mocktail` from `dependencies` to `dev_dependencies` in `pubspec.yaml`
- [ ] Run `flutter pub get` and verify no dependency warnings

### 1.4 Exit Criteria
```bash
flutter analyze      # Must pass with 0 issues
flutter test         # Must pass with 0 failures
flutter run          # Must launch without crashes
```

---

## Phase 2: Data Layer Completion 🔧
*Goal: Replace all stub repositories with real implementations.*  
*Estimated Effort: 4–5 days*

### 2.1 Implement `AdminRepositoryImpl`

**Status:** `SupabaseAdminDataSource` is fully implemented. `AdminRepositoryImpl` is a stub returning `ServerFailure(message: 'Not implemented')` for every method.

**Implementation:**
- [ ] Inject `AdminRemoteDataSource` into `AdminRepositoryImpl` constructor
- [ ] Delegate all methods to datasource with proper exception-to-failure mapping
- [ ] Handle specific Supabase errors: `PostgrestException`, `AuthException`, network errors
- [ ] Map to typed failures: `ServerFailure`, `NetworkFailure`, `AuthFailure`, `BusinessFailure`

**Methods to implement:**
```dart
Future<Either<Failure, List<AuthUser>>> getPendingUsers();
Future<Either<Failure, void>> approveUser(String userId);
Future<Either<Failure, void>> rejectUser(String userId, {String? reason});
Future<Either<Failure, void>> suspendUser(String userId);
Future<Either<Failure, List<AuthUser>>> getAllTeachers();
Future<Either<Failure, void>> assignStudentToTeacher(String studentId, String teacherId);
Future<Either<Failure, SystemStats>> getSystemStats();
Future<Either<Failure, ReportData>> generateReport({DateTime? startDate, DateTime? endDate});
Future<Either<Failure, SystemSettings>> getSystemSettings();
Future<Either<Failure, void>> updateSystemSettings(SystemSettings settings);
```

### 2.2 Implement `SessionsRepositoryImpl`

**Status:** `SupabaseSessionsDataSource` is fully implemented with UTC handling. `SessionsRepositoryImpl` is a stub.

**Implementation:**
- [ ] Inject `SessionsRemoteDataSource` into constructor
- [ ] Delegate CRUD operations with proper failure mapping
- [ ] Ensure UTC ↔ local time conversion is preserved in repository layer
- [ ] Handle edge cases: overlapping sessions, cancelled session modifications, past-date scheduling

**Methods to implement:**
```dart
Future<Either<Failure, Session>> getSessionById(String id);
Future<Either<Failure, List<Session>>> getSessionsByTeacher(String teacherId);
Future<Either<Failure, List<Session>>> getSessionsByStudent(String studentId);
Future<Either<Failure, Session>> createSession(Session session);
Future<Either<Failure, void>> assignStudentToSession(String sessionId, String studentId);
Future<Either<Failure, Session>> updateSession(Session session);
Future<Either<Failure, void>> cancelSession(String sessionId, {String? reason});
Future<Either<Failure, Session>> rescheduleSession(String sessionId, DateTime newDateTime);
Future<Either<Failure, void>> completeSession(String sessionId);
Future<Either<Failure, List<Session>>> getSessionsByDateRange(DateTime start, DateTime end);
```

### 2.3 Implement `ProfileRepositoryImpl`

**Status:** `SupabaseProfileDataSource` is fully implemented with avatar upload/delete to Supabase Storage. `ProfileRepositoryImpl` is a stub.

**Implementation:**
- [ ] Inject `ProfileRemoteDataSource` into constructor
- [ ] Delegate profile CRUD and avatar operations
- [ ] Handle storage errors separately from database errors
- [ ] Map avatar upload failures to `ServerFailure` or `NetworkFailure`

**Methods to implement:**
```dart
Future<Either<Failure, UserProfile>> getProfile(String userId);
Future<Either<Failure, UserProfile>> getProfileById(String userId);
Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);
Future<Either<Failure, String>> uploadAvatar(String userId, File imageFile);
Future<Either<Failure, void>> deleteAvatar(String userId);
Future<Either<Failure, List<AuthUser>>> getStudentsByTeacher(String teacherId);
Future<Either<Failure, List<AuthUser>>> getTeachersForStudent(String studentId);
Future<Either<Failure, void>> linkStudentToTeacher(String studentId, String teacherId);
Future<Either<Failure, void>> unlinkStudentFromTeacher(String studentId, String teacherId);
```

### 2.4 Complete `GradingRepositoryImpl` Real-Time Stream

**Status:** All methods implemented except `gradesStream` which returns `Stream.empty()` with a TODO.

**Implementation:**
- [ ] Integrate with `RealtimeService` or Supabase realtime directly
- [ ] Return `Stream<Either<Failure, List<ProgressGrade>>>` that updates on database changes
- [ ] Filter stream by `studentId` or `teacherId` as appropriate
- [ ] Handle stream errors by emitting `Left(NetworkFailure(...))`

### 2.5 Regenerate DI Configuration

- [ ] Update `@injectable` annotations on repository implementations to accept datasource dependencies
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify `injection.config.dart` wires datasources into repositories

### 2.6 Exit Criteria
- [ ] All stub repositories replaced with real implementations
- [ ] `flutter analyze` passes
- [ ] All repository methods have unit tests with mocked datasources (see Phase 6)
- [ ] Manual verification: AdminBloc, SessionsBloc, ProfileBloc can load real data

---

## Phase 3: Presentation Layer — Essential Screens 🎨
*Goal: Replace all placeholder screens with functional UIs.*  
*Estimated Effort: 10–14 days*

### 3.1 Profile Screen

**Current:** `Center(child: Text('ProfileScreen'))`

**Requirements:**
- [ ] Display user info: name, email, phone, role, avatar
- [ ] Editable fields with `flutter_form_builder` + `form_builder_validators`
- [ ] Avatar upload using `image_picker` + crop functionality
- [ ] Password change section (current + new + confirm)
- [ ] RTL-aware layout with proper Arabic text direction
- [ ] Loading states, error handling with `ErrorScreen`
- [ ] Localization keys for all strings

**Architecture:**
- Uses existing `ProfileBloc` (already fully implemented with 10 event handlers)
- Connects to `AuthBloc` for current user context

### 3.2 Sessions Screen (Student + Teacher)

**Current:** Both `SessionsScreen` and `SessionDetailScreen` are placeholders

**Requirements:**
- [ ] Calendar view using `table_calendar` with session markers
- [ ] List view for upcoming/past sessions
- [ ] Session cards showing: date/time, status, teacher/student name, surah/ayah info
- [ ] Filter by status (scheduled, completed, cancelled)
- [ ] Pull-to-refresh
- [ ] Empty state illustration/message
- [ ] Deep link handling for `/session/:id`

**Teacher-specific:**
- [ ] "Create Session" FAB with bottom sheet/dialog
- [ ] Assign student dropdown
- [ ] Cancel/reschedule actions

**Student-specific:**
- [ ] View-only with join session action (if virtual)

### 3.3 Session Detail Screen

**Requirements:**
- [ ] Full session info display
- [ ] Teacher: edit, cancel, complete, reschedule actions
- [ ] Student: view grades after completion
- [ ] Audio feedback playback (if graded) using `AudioService`
- [ ] Tajweed notes display
- [ ] Navigation to related progress/grading screens

### 3.4 Teacher Sessions Screen (`teacher_sessions_screen.dart`)

**Current:** `Center(child: Text('TeacherSessionsScreen'))`

**Requirements:**
- [ ] Dedicated teacher view of their sessions
- [ ] Quick actions: start session, mark attendance, grade student
- [ ] Session status management (scheduled → inProgress → completed)
- [ ] Integration with `SessionsBloc`

### 3.5 Teacher Students Screen (`teacher_students_screen.dart`)

**Current:** `Center(child: Text('TeacherStudentsScreen'))`

**Requirements:**
- [ ] List of assigned students with avatars
- [ ] Search/filter functionality
- [ ] Student detail view with progress summary
- [ ] Quick link to schedule session with student
- [ ] Link/unlink student actions

### 3.6 Admin Screens Completion

**Current:** `AdminDashboardScreen` has real UI. Other admin screens exist but may be basic.

**Pending Students Screen:**
- [ ] Table/list of pending registrations
- [ ] Approve/reject actions with confirmation dialogs
- [ ] Bulk approve/reject (nice-to-have)
- [ ] Auto-refresh when new registrations arrive

**Teacher Management Screen:**
- [ ] List of all teachers with stats (student count, session count)
- [ ] Assign/reassign students to teachers
- [ ] Teacher detail view

**Admin Sessions Screen:**
- [ ] Global view of all sessions across all teachers
- [ ] Filter by teacher, student, date range, status

**Reports Screen:**
- [ ] Date range picker
- [ ] Report preview with charts (`fl_chart`)
- [ ] PDF export using `PdfService`
- [ ] Share/download actions

**Admin Settings Screen:**
- [ ] System configuration forms
- [ ] Toggle features on/off
- [ ] Notification preferences

### 3.7 Student Home Screen Enhancement

**Current:** Basic `ListView` with 3 navigation cards

**Requirements:**
- [ ] Upcoming session card (next session highlight)
- [ ] Recent grades summary
- [ ] Progress overview with mini chart
- [ ] Quick actions: view sessions, view progress, edit profile
- [ ] Notification bell with unread count

### 3.8 Teacher Home Screen Enhancement

**Current:** Basic `ListView` with 3 navigation cards

**Requirements:**
- [ ] Today's sessions summary
- [ ] Pending grading reminders
- [ ] Student count overview
- [ ] Quick action: create session, grade student

### 3.9 Exit Criteria
- [ ] No placeholder screens remain in the app
- [ ] All screens use localization keys (no hardcoded strings)
- [ ] All screens handle loading, error, and empty states
- [ ] All screens are RTL-responsive
- [ ] Navigation between screens works correctly via `go_router`
- [ ] `flutter analyze` passes

---

## Phase 4: Student & Teacher Domain Layer 🏗️
*Goal: Clarify and implement domain layers for student/teacher features if needed.*  
*Estimated Effort: 3–4 days*

### 4.1 Architectural Decision Required

**Question:** Do `student/` and `teacher/` features need their own domain/data layers, or should they be pure presentation shells delegating to `profile`, `sessions`, and `grading` features?

**Recommendation:** Keep `student/` and `teacher/` as **presentation-only features** that compose BLoCs from other features. Their "home" screens aggregate data from `SessionsBloc`, `GradingBloc`, and `ProfileBloc`. This avoids duplication since:
- Student data = user profile + sessions + grades
- Teacher data = user profile + sessions + students (from profile datasource)

### 4.2 If Separate Domain Needed

If future requirements demand student/teacher-specific logic (e.g., teacher availability, student learning plans), then:
- [ ] Create `student/domain/entities/` (e.g., `LearningPlan`, `StudentStats`)
- [ ] Create `teacher/domain/entities/` (e.g., `TeacherAvailability`, `TeacherStats`)
- [ ] Create repository interfaces and use cases
- [ ] Implement datasources and repositories

**Decision:** Defer until Phase 6 unless required for Phase 3 features.

---

## Phase 5: Core Services & Production Readiness 🚀
*Goal: Implement offline support, notifications, analytics, and CI/CD.*  
*Estimated Effort: 8–10 days*

### 5.1 Offline Support (Drift Database)

**Current:** `OfflineDatabase` is an in-memory stub. Data is lost on app restart.

**Implementation:**
- [ ] Define Drift table schemas for:
  - `users` (cached profile data)
  - `sessions` (cached session data)
  - `grades` (cached grade data)
  - `sync_queue` (pending operations)
- [ ] Generate drift code with `build_runner`
- [ ] Implement `OfflineDatabase` with actual SQLite persistence
- [ ] Wire `OfflineService` to use real database
- [ ] Implement conflict resolution strategy (server wins vs. client wins by entity type)
- [ ] Add offline indicator in UI (`StaleDataBanner` already exists)

### 5.2 Local Notifications

**Current:** `flutter_local_notifications` is in `pubspec.yaml` but unused. Only OneSignal (remote push) is wired.

**Implementation:**
- [ ] Initialize `flutter_local_notifications` in `NotificationService`
- [ ] Schedule local reminders for:
  - Upcoming sessions (15 min before)
  - Daily memorization reminders (configurable)
- [ ] Handle notification tap to navigate to relevant screen
- [ ] Respect user preferences in `SystemSettings`

### 5.3 Push Notifications (OneSignal Integration)

**Current:** OneSignal SDK initialized but not fully integrated with app events.

**Implementation:**
- [ ] Send notification on: user approved, session scheduled, grade posted, session reminder
- [ ] Tag users with role and status for targeted messaging
- [ ] Handle deep links from notification payloads
- [ ] Test on both Android and iOS

### 5.4 Analytics (PostHog)

**Current:** `posthog_flutter` included, `AppEnvironment.enableAnalytics` exists, but no events tracked.

**Implementation:**
- [ ] Create `AnalyticsService` wrapper around PostHog
- [ ] Track key events:
  - Auth: sign_up, sign_in, sign_out, approval_received
  - Sessions: session_created, session_completed, session_cancelled
  - Grading: grade_submitted, audio_feedback_recorded
  - Admin: user_approved, user_rejected, report_generated
- [ ] Only enable in production (`AppEnvironment.enableAnalytics`)
- [ ] Never track PII or sensitive data

### 5.5 Crash Reporting

**Current:** `AppLogger` has a TODO for PostHog crash reporting.

**Implementation:**
- [ ] Integrate PostHog exception capture in `AppLogger.error()` and `AppLogger.wtf()`
- [ ] Capture `FlutterError.onError` and `PlatformDispatcher.onError`
- [ ] Include app version, build number, and environment in crash reports
- [ ] Respect `AppEnvironment.enableCrashReporting`

### 5.6 CI/CD Pipeline

**Current:** `.github/workflows/` directory exists but is empty.

**Implementation:**
- [ ] Create `.github/workflows/ci.yml`:
  ```yaml
  name: CI
  on: [push, pull_request]
  jobs:
    analyze-and-test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: subosito/flutter-action@v2
          with:
            flutter-version: '3.24.0'
        - run: flutter pub get
        - run: flutter analyze
        - run: flutter test --coverage
        - run: flutter test integration_test/
  ```
- [ ] Add build jobs for Android APK and iOS
- [ ] Add coverage reporting (Codecov or similar)
- [ ] Protect main branch with CI pass requirement

### 5.7 Accessibility

- [ ] Add semantic labels to all interactive widgets
- [ ] Ensure proper contrast ratios (already good with `AppColors`)
- [ ] Test with screen readers (TalkBack/VoiceOver)
- [ ] Add `Semantics` widgets where automatic labels are insufficient

### 5.8 Exit Criteria
- [ ] App works offline with cached data
- [ ] Local notifications fire correctly
- [ ] Push notifications received on real devices
- [ ] Analytics events visible in PostHog dashboard
- [ ] CI pipeline passes on every PR
- [ ] Accessibility audit passes

---

## Phase 6: Comprehensive Test Coverage 🧪
*Goal: Achieve 80%+ coverage for domain, data, and BLoC layers.*  
*Estimated Effort: 7–10 days*

### 6.1 Fix Remaining Failing Tests (from Phase 1)
Already addressed. Ensure they stay passing.

### 6.2 Data Layer Tests

For each feature, create:
- **Model tests:** Verify `fromJson`/`toJson`, entity mapping, `Equatable`, `copyWith`
- **Datasource tests:** Mock Supabase client, verify query parameters, test error scenarios
- **Repository tests:** Mock datasources, verify failure mapping, test success paths

**Missing test files to create:**

| Feature | Model Tests | Datasource Tests | Repository Tests |
|---------|-------------|------------------|------------------|
| **auth** | `user_model_test.dart` | `auth_local_datasource_test.dart` | Fix existing |
| **admin** | N/A (no models) | `admin_remote_datasource_test.dart` | `admin_repository_impl_test.dart` |
| **sessions** | `session_model_test.dart` | Fix placeholder | `sessions_repository_impl_test.dart` |
| **grading** | `grade_model_test.dart` | `grading_remote_datasource_test.dart` | `grading_repository_impl_test.dart` |
| **profile** | `profile_model_test.dart` | `profile_remote_datasource_test.dart` | `profile_repository_impl_test.dart` |

### 6.3 Domain Layer Tests

**Missing usecase tests:**
- `auth/domain/usecases/get_current_user_usecase_test.dart`
- `auth/domain/usecases/sign_out_usecase_test.dart`
- `auth/domain/usecases/reset_password_usecase_test.dart`
- `profile/domain/usecases/get_profile_usecase_test.dart`
- `profile/domain/usecases/update_profile_usecase_test.dart`

### 6.4 BLoC Tests

**Missing bloc tests:**
- `admin/presentation/admin_bloc_test.dart` (14 events)
- `grading/presentation/grading_bloc_test.dart` (12 events)
- `profile/presentation/profile_bloc_test.dart` (10 events)
- `sessions/presentation/sessions_bloc_test.dart` (14 events)

### 6.5 Widget Tests

**Missing screen tests:**
- All admin screens (except dashboard)
- All teacher screens
- Profile screen
- Sessions screen + detail screen
- Progress screen
- Student home screen (fix existing)

### 6.6 Integration Tests

- [ ] Expand `integration_test/auth_flow_test.dart` to cover:
  - Sign up → pending → approval → home
  - Teacher signup with invite code
  - Password reset flow
- [ ] Add `integration_test/student_flow_test.dart`:
  - Login as student → view sessions → view progress → edit profile
- [ ] Add `integration_test/teacher_flow_test.dart`:
  - Login as teacher → create session → grade student → view students

### 6.7 Test Infrastructure Improvements

- [ ] Create `test/helpers/` directory with:
  - `fake_classes.dart` — centralized `FakeAuthEvent`, `FakeAdminEvent`, etc.
  - `test_data.dart` — fixture objects for entities and models
  - `pump_app.dart` — helper to pump app with all required BLoCs/providers
- [ ] Add `test_coverage` package or configure `flutter test --coverage` in CI

### 6.8 Exit Criteria
- [ ] `flutter test` passes with 0 failures
- [ ] Coverage report generated
- [ ] Domain layer: 80%+ coverage
- [ ] Data layer: 80%+ coverage
- [ ] BLoC layer: 80%+ coverage
- [ ] Presentation layer: 60%+ coverage (widget tests)

---

## Phase 7: Polish & Performance ✨
*Goal: Ensure production-grade quality.*  
*Estimated Effort: 3–4 days*

### 7.1 Performance
- [ ] Add `CachedNetworkImage` for all avatar images with placeholder and error widgets
- [ ] Implement list pagination with `CursorPagination` for large datasets
- [ ] Add `RepaintBoundary` around complex charts
- [ ] Debounce search inputs
- [ ] Optimize `build` methods — extract widgets, avoid unnecessary rebuilds

### 7.2 Error Handling UX
- [ ] Ensure all async operations show loading indicators
- [ ] Add retry buttons for all network-dependent screens
- [ ] Implement graceful degradation when offline
- [ ] Add toast/snackbar confirmations for successful actions

### 7.3 Asset Management
- [ ] Add actual app icon and launcher icons for Android/iOS
- [ ] Add splash screen image
- [ ] Add empty state illustrations to `assets/images/`
- [ ] Add notification icon to `assets/icons/`

### 7.4 Documentation
- [ ] Update `PROJECT_SUMMARY.md` with Phase 3 completion status
- [ ] Update `PHASE3_PROGRESS.md` to reflect 100% completion
- [ ] Remove stale Firebase references from documentation
- [ ] Add `TESTING_GUIDE.md` with instructions for running tests and adding new ones
- [ ] Add `DEPLOYMENT_GUIDE.md` with build commands and store submission steps

### 7.5 Security Audit
- [ ] Verify Row Level Security (RLS) policies in Supabase for all tables
- [ ] Ensure no sensitive data logged in `AppLogger`
- [ ] Review `Sanitizer` usage on all user inputs
- [ ] Verify Supabase Storage bucket permissions for avatars and recordings

---

## Implementation Priority Matrix

| Priority | Phase | Impact | Effort | Risk |
|----------|-------|--------|--------|------|
| **P0** | Phase 1: Critical Fixes | High | Low | Low |
| **P0** | Phase 2: Data Layer | High | Medium | Medium |
| **P1** | Phase 3: Presentation Layer | High | High | Medium |
| **P1** | Phase 6: Test Coverage | High | High | Low |
| **P2** | Phase 5: Core Services | Medium | High | High |
| **P2** | Phase 4: Domain Layer | Low | Medium | Low |
| **P3** | Phase 7: Polish | Medium | Medium | Low |

---

## Effort Summary

| Phase | Estimated Days | Cumulative |
|-------|----------------|------------|
| Phase 1: Critical Fixes | 2–3 | 2–3 |
| Phase 2: Data Layer | 4–5 | 6–8 |
| Phase 3: Presentation Layer | 10–14 | 16–22 |
| Phase 4: Domain Layer | 3–4 | 19–26 |
| Phase 5: Core Services | 8–10 | 27–36 |
| Phase 6: Test Coverage | 7–10 | 34–46 |
| Phase 7: Polish | 3–4 | 37–50 |

**Total estimated effort: 37–50 engineering days** (~2.5 months with 1 senior Flutter developer)

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Supabase schema changes break data layer | Medium | High | Document schema, add migration scripts, version APIs |
| RTL layout issues in complex screens | Medium | Medium | Test every screen in Arabic, use `Directionality` widget |
| Audio recording fails on certain devices | Medium | Medium | Test on multiple devices, add fallback error UI |
| Offline sync conflicts | Medium | High | Implement clear conflict resolution, prefer server wins |
| CI environment lacks Flutter SDK | Low | Medium | Use `subosito/flutter-action`, pin Flutter version |
| OneSignal configuration issues | Medium | Medium | Test push notifications early, have fallback local notifications |
| Performance issues with large datasets | Low | High | Implement pagination, lazy loading, image caching early |

---

## Success Metrics

At the end of this upgrade plan, the app should:

1. ✅ **Build and run** with `flutter run` without any compilation errors
2. ✅ **Pass all tests** — `flutter test` with 0 failures
3. ✅ **Pass static analysis** — `flutter analyze` with 0 issues
4. ✅ **Support all 3 roles** with functional, non-placeholder screens
5. ✅ **Work offline** with cached data and sync when reconnected
6. ✅ **Send/receive notifications** (both local and push)
7. ✅ **Export reports** to PDF
8. ✅ **Record and playback** Tajweed audio feedback
9. ✅ **Track analytics** events in production
10. ✅ **Have CI/CD** that builds and tests on every commit
11. ✅ **Achieve 80%+ test coverage** for domain, data, and BLoC layers
12. ✅ **Be ready for app store submission** (iOS App Store + Google Play)

---

## Appendix: Immediate Next Steps (Today)

If you are starting this plan **right now**, do these in order:

1. `flutter analyze` — see current issues
2. `flutter test` — see failing tests
3. Fix the 5 `auth_repository_impl_test.dart` failures (typed failures)
4. Fix the 4 `student_home_screen_test.dart` failures (fallback values)
5. Fix the 5 `admin_dashboard_screen_test.dart` failures (fallback values)
6. Fix the 2 `login_screen_test.dart` failures (matchers)
7. Fix the raw string bug in `AppLocalizations`
8. Fix the realtime subscription leak
9. Implement `AdminRepositoryImpl` (fastest win — datasource already done)
10. Implement `SessionsRepositoryImpl`
11. Implement `ProfileRepositoryImpl`

After these 11 items, the app will be **stable, tested, and have working data layers for all features** — a strong foundation for building the presentation layer.
