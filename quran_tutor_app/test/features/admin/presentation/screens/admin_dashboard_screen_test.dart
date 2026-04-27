import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() {
  group('AdminDashboardScreen', () {
    testWidgets('should render admin dashboard placeholder', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminDashboardScreen(),
        ),
      );

      // assert
      expect(find.text('AdminDashboardScreen'), findsOneWidget);
    });
  });
}
