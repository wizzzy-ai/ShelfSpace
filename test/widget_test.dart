import 'package:flutter_test/flutter_test.dart';
import 'package:biblira/main.dart';

void main() {
  testWidgets('Biblira smoke test', (WidgetTester tester) async {
    // Build BibliraApp and trigger initial frame.
    await tester.pumpWidget(const BibliraApp());

    // Verify initial splash screen branding
    expect(find.text('BIBLIRA'), findsOneWidget);
    expect(find.text('Your World of Books'), findsOneWidget);

    // Fast forward past splash timer (2800ms)
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify onboarding screen is presented
    expect(find.text('Discover Your Next Great Read'), findsOneWidget);
  });
}
