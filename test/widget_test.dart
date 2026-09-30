import 'package:flutter_test/flutter_test.dart';
import 'package:biblira/main.dart';

void main() {
  testWidgets('ShelfSpace smoke test', (WidgetTester tester) async {
    // Build the app and trigger the initial frame.
    await tester.pumpWidget(const ShelfSpaceApp());

    // Verify initial splash screen branding
    expect(find.text('SHELFSPACE'), findsOneWidget);
    expect(find.text('Your World of Books'), findsOneWidget);

    // Fast forward past splash timer (2800ms)
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify onboarding screen is presented
    expect(find.text('Discover Your\nNext Great Read'), findsOneWidget);
  });
}
