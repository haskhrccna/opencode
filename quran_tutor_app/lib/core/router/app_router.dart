import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/student/presentation/screens/student_home_screen.dart';
import '../../features/teacher/presentation/screens/teacher_home_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/pending_students_screen.dart';
import '../../features/admin/presentation/screens/teacher_management_screen.dart';
import '../../features/sessions/presentation/screens/sessions_screen.dart';
import '../../features/sessions/presentation/screens/session_detail_screen.dart';
import '../../features/grading/presentation/screens/progress_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/error_screen.dart';
import '../constants/app_constants.dart';
import '../error/failures.dart';
import '../localization/app_localizations.dart';

/// Application router configuration
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Redirect based on auth state
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      final isSplash = state.path == '/splash';
      final isAuthRoute = state.path?.startsWith('/auth') ?? false;

      // Don't redirect during initial load
      if (authState is AuthInitial || authState is AuthLoading) {
        return isSplash ? null : '/splash';
      }

      // Handle authenticated state
      if (authState is Authenticated) {
        final user = authState.user;

        // Check user status
        if (user.status == UserStatus.pending && user.role != UserRole.admin) {
          return '/pending-approval';
        }

        if (user.status == UserStatus.rejected) {
          return '/rejected';
        }

        // Redirect from auth routes to home
        if (isAuthRoute || isSplash) {
          return _getHomeRoute(user.role);
        }

        // Check role-based access
        final requestedPath = state.path ?? '/';
        if (!_hasAccess(user.role, requestedPath)) {
          return _getHomeRoute(user.role);
        }

        return null;
      }

      // Handle unauthenticated state
      if (authState is Unauthenticated) {
        if (!isAuthRoute && !isSplash) {
          return '/auth/login';
        }
        return null;
      }

      // Handle auth errors
      if (authState is AuthError) {
        if (!isAuthRoute && !isSplash) {
          return '/auth/login';
        }
        return null;
      }

      return null;
    },

    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth',
        redirect: (_, state) => state.path == '/auth' ? '/auth/login' : null,
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      ),

      // Pending Approval
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),

      // Rejected
      GoRoute(
        path: '/rejected',
        builder: (context, state) => const RejectedScreen(),
      ),

      // Student Routes
      GoRoute(
        path: '/student',
        redirect: (_, state) => state.path == '/student' ? '/student/home' : null,
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) => const StudentHomeScreen(),
          ),
          GoRoute(
            path: 'sessions',
            builder: (context, state) => const SessionsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final sessionId = state.pathParameters['id']!;
                  return SessionDetailScreen(sessionId: sessionId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Teacher Routes
      GoRoute(
        path: '/teacher',
        redirect: (_, state) => state.path == '/teacher' ? '/teacher/home' : null,
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) => const TeacherHomeScreen(),
          ),
          GoRoute(
            path: 'sessions',
            builder: (context, state) => const TeacherSessionsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final sessionId = state.pathParameters['id']!;
                  return SessionDetailScreen(sessionId: sessionId, isTeacher: true);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'students',
            builder: (context, state) => const TeacherStudentsScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        redirect: (_, state) => state.path == '/admin' ? '/admin/dashboard' : null,
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: 'pending',
            builder: (context, state) => const PendingStudentsScreen(),
          ),
          GoRoute(
            path: 'teachers',
            builder: (context, state) => const TeacherManagementScreen(),
          ),
          GoRoute(
            path: 'sessions',
            builder: (context, state) => const AdminSessionsScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],

    // Error Page - Convert Exception to Failure
    errorBuilder: (context, state) {
      final failure = state.error is Failure 
          ? state.error as Failure 
          : UnknownFailure(message: state.error?.toString() ?? 'Unknown error');
      return ErrorScreen(failure: failure);
    },
  );

  /// Get home route based on user role
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

  /// Check if user has access to a specific route
  static bool _hasAccess(UserRole role, String path) {
    final rolePrefix = '/${role.value}';

    // Admin has access to everything
    if (role == UserRole.admin) {
      return true;
    }

    // Students and teachers can only access their own routes
    if (path.startsWith('/student') && role == UserRole.student) {
      return true;
    }

    if (path.startsWith('/teacher') && role == UserRole.teacher) {
      return true;
    }

    // Auth routes are accessible to everyone
    if (path.startsWith('/auth') || path == '/splash') {
      return true;
    }

    return false;
  }
}

// Placeholder screens (to be implemented in respective features)
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              l10n.t('pending.title'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(l10n.t('pending.message')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: Text(l10n.t('pending.logout')),
            ),
          ],
        ),
      ),
    );
  }
}

class RejectedScreen extends StatelessWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              l10n.t('rejected.title'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(l10n.t('rejected.message')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              child: Text(l10n.t('rejected.logout')),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherSessionsScreen extends StatelessWidget {
  const TeacherSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AdminSessionsScreen extends StatelessWidget {
  const AdminSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


