import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_sessions_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/pending_students_screen.dart';
import '../../features/admin/presentation/screens/reports_screen.dart';
import '../../features/admin/presentation/screens/teacher_management_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/pending_approval_screen.dart';
import '../../features/auth/presentation/screens/rejected_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/grading/presentation/screens/progress_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/sessions/presentation/screens/session_detail_screen.dart';
import '../../features/sessions/presentation/screens/sessions_screen.dart';
import '../../features/student/presentation/screens/student_home_screen.dart';
import '../../features/teacher/presentation/screens/teacher_home_screen.dart';
import '../../features/teacher/presentation/screens/teacher_sessions_screen.dart';
import '../../features/teacher/presentation/screens/teacher_students_screen.dart';
import '../../shared/widgets/error_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    redirect: _redirect,
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
      redirect: (_, state) => state.path == '/auth' ? '/auth/login' : null,
      routes: [
        GoRoute(path: 'login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: 'signup', builder: (_, __) => const SignupScreen()),
      ],
    ),
    GoRoute(
      path: '/pending-approval',
      builder: (_, __) => const PendingApprovalScreen()),
    GoRoute(
      path: '/rejected', builder: (_, __) => const RejectedScreen()),
    GoRoute(
      path: '/student',
      redirect: (_, state) =>
          state.path == '/student' ? '/student/home' : null,
      routes: [
        GoRoute(
          path: 'home', builder: (_, __) => const StudentHomeScreen()),
        GoRoute(
          path: 'sessions',
          builder: (_, __) => const SessionsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => SessionDetailScreen(
                sessionId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'progress', builder: (_, __) => const ProgressScreen()),
        GoRoute(
          path: 'profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/teacher',
      redirect: (_, state) =>
          state.path == '/teacher' ? '/teacher/home' : null,
      routes: [
        GoRoute(
          path: 'home', builder: (_, __) => const TeacherHomeScreen()),
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
          builder: (_, __) => const TeacherStudentsScreen()),
        GoRoute(
          path: 'profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/admin',
      redirect: (_, state) =>
          state.path == '/admin' ? '/admin/dashboard' : null,
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (_, __) => const AdminDashboardScreen()),
        GoRoute(
          path: 'pending',
          builder: (_, __) => const PendingStudentsScreen()),
        GoRoute(
          path: 'teachers',
          builder: (_, __) => const TeacherManagementScreen()),
        GoRoute(
          path: 'sessions',
          builder: (_, __) => const AdminSessionsScreen()),
        GoRoute(
          path: 'reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(
          path: 'settings',
          builder: (_, __) => const AdminSettingsScreen()),
      ],
    ),
  ];

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    final isSplash = state.path == '/splash';
    final isAuthRoute = state.path?.startsWith('/auth') ?? false;

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
      final requestedPath = state.path ?? '/';
      if (!_hasAccess(user.role, requestedPath)) {
        return _getHomeRoute(user.role);
      }
      return null;
    }

    if (authState.status == AuthStatus.pendingApproval) {
      if (state.path == '/pending-approval') return null;
      return '/pending-approval';
    }

    if (authState.status == AuthStatus.rejected) {
      if (state.path == '/rejected') return null;
      return '/rejected';
    }

    if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.error) {
      if (!isAuthRoute && !isSplash) return '/auth/login';
      return null;
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
    if (role == UserRole.admin) return true;
    if (path.startsWith('/student') && role == UserRole.student) return true;
    if (path.startsWith('/teacher') && role == UserRole.teacher) return true;
    if (path.startsWith('/auth') || path == '/splash') return true;
    return false;
  }
}
