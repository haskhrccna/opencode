import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/features/auth/domain/entities/auth_user.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/student/presentation/screens/student_home_screen.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest(AuthState state) {
    when(() => mockAuthBloc.state).thenReturn(state);
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(state));
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const StudentHomeScreen(),
      ),
    );
  }

  group('StudentHomeScreen', () {
    testWidgets('should show loading when user is null', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(const AuthState.initial()));

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render user name in app bar', (tester) async {
      // arrange
      final user = AuthUser(
        id: 'user-123',
        email: 'student@example.com',
        displayName: 'Student User',
        arabicName: 'طالب تجريبي',
        role: UserRole.student,
        status: UserStatus.approved,
        createdAt: DateTime.now(),
      );
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // assert
      expect(find.textContaining('مرحباً'), findsOneWidget);
      expect(find.textContaining('طالب تجريبي'), findsOneWidget);
    });

    testWidgets('should render navigation cards', (tester) async {
      // arrange
      final user = AuthUser(
        id: 'user-123',
        email: 'student@example.com',
        displayName: 'Student User',
        arabicName: 'طالب تجريبي',
        role: UserRole.student,
        status: UserStatus.approved,
        createdAt: DateTime.now(),
      );
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // assert
      expect(find.text('جلساتي'), findsOneWidget);
      expect(find.text('تقدمي'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);
    });

    testWidgets('should call SignOutRequested when logout tapped', (tester) async {
      // arrange
      final user = AuthUser(
        id: 'user-123',
        email: 'student@example.com',
        displayName: 'Student User',
        arabicName: 'طالب تجريبي',
        role: UserRole.student,
        status: UserStatus.approved,
        createdAt: DateTime.now(),
      );
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pump();

      // assert
      verify(() => mockAuthBloc.add(const SignOutRequested())).called(1);
    });
  });
}
