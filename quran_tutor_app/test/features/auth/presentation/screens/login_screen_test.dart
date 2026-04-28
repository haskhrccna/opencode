import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthState.initial());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(const AuthState.initial()));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('should render login form', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('دخول'), findsOneWidget);
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
    });

    testWidgets('should show error for invalid email', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('دخول'));
      await tester.pump();

      // assert
      expect(find.textContaining('valid'), findsOneWidget);
    });

    testWidgets('should show error for empty password', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('دخول'));
      await tester.pump();

      // assert
      expect(find.textContaining('password'), findsOneWidget);
    });

    testWidgets('should call SignInRequested on valid form submit', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.add(any())).thenReturn(null);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123',
      );
      await tester.tap(find.text('دخول'));
      await tester.pump();

      // assert
      verify(() => mockAuthBloc.add(
        const SignInRequested(
          email: 'test@example.com',
          password: 'Password123',
        ),
      )).called(1);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(
        const AuthState(status: AuthStatus.loading),
      );
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const AuthState(status: AuthStatus.loading)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar on error', (WidgetTester tester) async {
      // arrange
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthState.initial(),
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'Invalid credentials',
          ),
        ]),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
