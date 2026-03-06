import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decp_mobile_app/main.dart';
import 'package:decp_mobile_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('App starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Riverpod and GoRouter initialization might require pumpAndSettle
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}
