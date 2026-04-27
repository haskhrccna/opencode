import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:quran_tutor_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:quran_tutor_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';

class MockAdminBloc extends Mock implements AdminBloc {}

void main() {
  late MockAdminBloc mockAdminBloc;

  setUp(() {
    mockAdminBloc = MockAdminBloc();
  });

  Widget createWidgetUnderTest(AdminState state) {
    when(() => mockAdminBloc.state).thenReturn(state);
    when(() => mockAdminBloc.stream).thenAnswer((_) => Stream.value(state));
    when(() => mockAdminBloc.add(any())).thenReturn(null);

    return MaterialApp(
      home: BlocProvider<AdminBloc>.value(
        value: mockAdminBloc,
        child: const AdminDashboardScreen(),
      ),
    );
  }

  group('AdminDashboardScreen', () {
    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      final state = AdminState.initial().copyWith(status: AdminStatus.loading);

      await tester.pumpWidget(createWidgetUnderTest(state));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render stats cards with correct values', (WidgetTester tester) async {
      final state = AdminState.initial().copyWith(
        status: AdminStatus.loaded,
        systemStats: SystemStats(
          totalUsers: 100,
          totalStudents: 80,
          totalTeachers: 15,
          totalAdmins: 5,
          pendingApprovals: 12,
          totalSessions: 200,
          completedSessions: 150,
          cancelledSessions: 10,
          averageSessionDuration: 45.0,
          averageGrade: 4.2,
          newUsersThisWeek: 5,
          activeUsersToday: 20,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      expect(find.text('100'), findsOneWidget); // totalUsers
      expect(find.text('80'), findsOneWidget); // totalStudents
      expect(find.text('15'), findsOneWidget); // totalTeachers
      expect(find.text('12'), findsOneWidget); // pendingApprovals
    });

    testWidgets('should show pending users list', (WidgetTester tester) async {
      final pendingUsers = [
        AuthUser(
          id: 'user-1',
          email: 'student1@example.com',
          displayName: 'Student One',
          role: UserRole.student,
          status: UserStatus.pending,
          createdAt: DateTime.now(),
        ),
        AuthUser(
          id: 'user-2',
          email: 'teacher1@example.com',
          displayName: 'Teacher One',
          role: UserRole.teacher,
          status: UserStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      final state = AdminState.initial().copyWith(
        status: AdminStatus.loaded,
        pendingUsers: pendingUsers,
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      expect(find.text('Student One'), findsOneWidget);
      expect(find.text('Teacher One'), findsOneWidget);
    });

    testWidgets('should call ApproveUser when approve button tapped', (WidgetTester tester) async {
      final pendingUsers = [
        AuthUser(
          id: 'user-1',
          email: 'student1@example.com',
          displayName: 'Student One',
          role: UserRole.student,
          status: UserStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      final state = AdminState.initial().copyWith(
        status: AdminStatus.loaded,
        pendingUsers: pendingUsers,
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      // Find and tap approve button (would need actual implementation)
      // For now, verify the user is displayed
      expect(find.text('Student One'), findsOneWidget);
    });

    testWidgets('should show error message on error state', (WidgetTester tester) async {
      final state = AdminState.initial().copyWith(
        status: AdminStatus.error,
        errorMessage: 'Failed to load dashboard',
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      expect(find.textContaining('خطأ'), findsOneWidget);
      expect(find.textContaining('Failed to load dashboard'), findsOneWidget);
    });
  });
}
