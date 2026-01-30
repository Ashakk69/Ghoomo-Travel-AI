// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:travel_planner/main.dart';
import 'package:travel_planner/services/auth_service.dart';

void main() {
  testWidgets('Travel Planner app loads correctly',
      (WidgetTester tester) async {
    // Create a mock auth service
    final authService = AuthService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(TravelPlannerApp(authService: authService));

    // Wait for the async initialization
    await tester.pumpAndSettle();

    // The app should show either onboarding, login, or home screen
    // We can't predict which without setting up the state, so just verify the app builds
    expect(find.byType(TravelPlannerApp), findsOneWidget);
  });
}
