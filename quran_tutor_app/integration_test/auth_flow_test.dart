import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quran_tutor_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Integration Tests', () {
    testWidgets('Golden path: Splash → Login → Student Home', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for splash to complete
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.text('تسجيل الدخول'), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123',
      );

      // Submit login
      await tester.tap(find.text('دخول'));
      await tester.pumpAndSettle();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for navigation
      await tester.pumpAndSettle();

      // Should be on student home
      expect(find.textContaining('مرحباً'), findsOneWidget);
    });

    testWidgets('Login with bad credentials shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for login screen
      await tester.pumpAndSettle();
      expect(find.text('تسجيل الدخول'), findsOneWidget);

      // Enter invalid credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        'wrong@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'wrongpassword',
      );

      // Submit login
      await tester.tap(find.text('دخول'));
      await tester.pumpAndSettle();

      // Wait for error
      await tester.pumpAndSettle();

      // Should show error
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('New registration → pending screen flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for login screen
      await tester.pumpAndSettle();

      // Navigate to signup
      await tester.tap(find.text('إنشاء حساب جديد'));
      await tester.pumpAndSettle();

      // Should be on signup screen
      expect(find.textContaining('حساب'), findsOneWidget);

      // Fill registration form
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'newstudent@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'New Student',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'طالب جديد',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'Password123',
      );

      // Submit registration
      await tester.tap(find.text('تسجيل'));
      await tester.pumpAndSettle();

      // Wait for navigation to pending screen
      await tester.pumpAndSettle();

      // Should show pending approval
      expect(find.text('طلبك قيد المراجعة'), findsOneWidget);
    });
  });
}
