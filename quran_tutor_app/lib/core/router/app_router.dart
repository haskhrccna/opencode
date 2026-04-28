import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/admin_sessions_screen.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/pending_students_screen.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/reports_screen.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/teacher_management_screen.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/login_screen.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/rejected_screen.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/teacher_signup_screen.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:quran_tutor_app/features/grading/presentation/screens/progress_screen.dart';
import 'package:quran_tutor_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:quran_tutor_app/features/sessions/presentation/screens/session_detail_screen.dart';
import 'package:quran_tutor_app/features/sessions/presentation/screens/sessions_screen.dart';
import 'package:quran_tutor_app/features/student/presentation/screens/student_home_screen.dart';
import 'package:quran_tutor_app/features/teacher/presentation/screens/teacher_home_screen.dart';
import 'package:quran_tutor_app/features/teacher/presentation/screens/teacher_sessions_screen.dart';
import 'package:quran_tutor_app/features/teacher/presentation/screens/teacher_students_screen.dart';
import 'package:quran_tutor_app/shared/widgets/error_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Notifies go_router to re-evaluate redirects when auth state changes
  static final ValueNotifier<AuthStatus> authRefreshNotifier = ValueNotifier<AuthStatus>(AuthStatus.initial);

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    redirect: _redirect,
    refreshListenable: authRefreshNotifier,
    routes: _routes,
    errorBuilder: (_, state) => ErrorScreen(customMessage: state.error?.toString()),
  );

  static final List<RouteBase> _routes = [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    // Deep link: Teacher invite code
    GoRoute(
      path: '/invite/:code',
      builder: (_, state) {
        final code = state.pathParameters['code']!;
        return SignupScreen(teacherInviteCode: code);
      },
    ),
    // Deep link: Session link
    GoRoute(
      path: '/session/:id',
      builder: (_, state) {
        final sessionId = state.pathParameters['id']!;
        return SessionDetailScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/auth',
      redirect: (_, state) =>
          state.uri.path == '/auth' ? '/auth/login' : null,
      routes: [
        GoRoute(path: 'login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: 'signup', builder: (_, __) => const SignupScreen()),
        GoRoute(path: 'teacher-signup', builder: (_, __) => const TeacherSignupScreen()),
      ],
    ),
    GoRoute(
      path: '/pending-approval',
      builder: (_, __) => const PendingApprovalScreen(),),
    GoRoute(
      path: '/rejected', builder: (_, __) => const RejectedScreen(),),
    GoRoute(
      path: '/student',
      redirect: (_, state) =>
          state.uri.path == '/student' ? '/student/home' : null,
      routes: [
        GoRoute(
          path: 'home', builder: (_, __) => const StudentHomeScreen(),),
        GoRoute(
          path: 'sessions',
          builder: (_, __) => const SessionsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => SessionDetailScreen(
                sessionId: state.pathParameters['id']!,),
            ),
          ],
        ),
        GoRoute(
          path: 'progress', builder: (_, __) => const ProgressScreen(),),
        GoRoute(
          path: 'profile', builder: (_, __) => const ProfileScreen(),),
      ],
    ),
    GoRoute(
      path: '/teacher',
      redirect: (_, state) =>
          state.uri.path == '/teacher' ? '/teacher/home' : null,
      routes: [
        GoRoute(
          path: 'home', builder: (_, __) => const TeacherHomeScreen(),),
        GoRoute(
          path: 'sessions',
          builder: (_, __) => const TeacherSessionsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => SessionDetailScreen(
                sessionId: state.pathParameters['id']!,
                isTeacher: true,
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'students',
          builder: (_, __) => const TeacherStudentsScreen(),),
        GoRoute(
          path: 'profile', builder: (_, __) => const ProfileScreen(),),
      ],
    ),
    GoRoute(
      path: '/admin',
      redirect: (_, state) =>
          state.uri.path == '/admin' ? '/admin/dashboard' : null,
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (_, __) => const AdminDashboardScreen(),),
        GoRoute(
          path: 'pending',
          builder: (_, __) => const PendingStudentsScreen(),),
        GoRoute(
          path: 'teachers',
          builder: (_, __) => const TeacherManagementScreen(),),
        GoRoute(
          path: 'sessions',
          builder: (_, __) => const AdminSessionsScreen(),),
        GoRoute(
          path: 'reports', builder: (_, __) => const ReportsScreen(),),
        GoRoute(
          path: 'settings',
          builder: (_, __) => const AdminSettingsScreen(),),
      ],
    ),
  ];

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // Use the actual URL path, not the matched route pattern.
    final location = state.uri.path;
    final isSplash = location == '/splash';
    final isAuthRoute = location.startsWith('/auth');

    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return isSplash ? null : '/splash';
    }

    if (authState.status == AuthStatus.authenticated) {
      final user = authState.user;
      if (user == null) return '/auth/login';
      if (isAuthRoute || isSplash) {
        return _getHomeRoute(user.role);
      }
      if (!_hasAccess(user.role, location)) {
        return _getHomeRoute(user.role);
      }
      return null;
    }

    if (authState.status == AuthStatus.pendingApproval) {
      if (location == '/pending-approval') return null;
      return '/pending-approval';
    }

    if (authState.status == AuthStatus.rejected) {
      if (location == '/rejected') return null;
      return '/rejected';
    }

    if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.error) {
      // Auth has resolved: never strand the user on /splash.
      if (isAuthRoute) return null;
      return '/auth/login';
    }

    return null;
  }

  static String _getHomeRoute(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '/student/home';
      case UserRole.teacher:
        return '/teacher/home';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }

  static bool _hasAccess(UserRole role, String path) {
    // Deep-link routes are reachable by any authenticated role.
    if (_isDeepLinkPath(path)) return true;
    if (role == UserRole.admin) return true;
    if (path.startsWith('/student') && role == UserRole.student) return true;
    if (path.startsWith('/teacher') && role == UserRole.teacher) return true;
    if (path.startsWith('/auth') || path == '/splash') return true;
    return false;
  }

  static bool _isDeepLinkPath(String path) {
    // [path] is the URL path (e.g. "/session/abc-123" or "/invite/XYZ").
    return path.startsWith('/session/') || path.startsWith('/invite/');
  }
}
