import 'package:biblira/screens/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  Future<void> scrollToTile(
    WidgetTester tester,
    String title,
  ) async {
    await tester.scrollUntilVisible(
      find.text(title),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(title));
    await tester.pumpAndSettle();
  }

  testWidgets('Help & Support opens the help screen', (tester) async {
    await openSettings(tester);

    final helpTile = find.text('Help & Support');
    await scrollToTile(tester, 'Help & Support');
    await tester.tap(helpTile);
    await tester.pumpAndSettle();

    expect(find.text('Frequently Asked Questions'), findsOneWidget);
  });

  testWidgets('Terms & Conditions opens the terms document', (tester) async {
    await openSettings(tester);

    final termsTile = find.text('Terms & Conditions');
    await scrollToTile(tester, 'Terms & Conditions');
    await tester.tap(termsTile);
    await tester.pumpAndSettle();

    expect(find.text('Using ShelfSpace'), findsOneWidget);
    expect(find.text('Orders and payment'), findsOneWidget);
  });

  testWidgets('Privacy Policy opens the privacy document', (tester) async {
    await openSettings(tester);

    final privacyTile = find.text('Privacy Policy');
    await scrollToTile(tester, 'Privacy Policy');
    await tester.tap(privacyTile);
    await tester.pumpAndSettle();

    expect(find.text('Your information and privacy'), findsOneWidget);
    expect(find.text('Information you provide'), findsOneWidget);
  });
}
