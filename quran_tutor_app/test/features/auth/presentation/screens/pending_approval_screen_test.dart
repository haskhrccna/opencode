import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/auth/presentation/screens/pending_approval_screen.dart';

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
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const PendingApprovalScreen(),
      ),
    );
  }

  group('PendingApprovalScreen', () {
    testWidgets('should render pending approval UI', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
      expect(find.text('طلبك قيد المراجعة'), findsOneWidget);
      expect(find.text('سيتم إشعارك عند الموافقة على طلبك'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);
    });

    testWidgets('should call SignOutRequested when logout tapped', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pump();

      // assert
      verify(() => mockAuthBloc.add(const SignOutRequested())).called(1);
    });
  });
}
