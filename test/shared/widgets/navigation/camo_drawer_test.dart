import 'package:camo/shared/widgets/navigation/camo_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drawer has exactly one metadata-only History entry', (
    WidgetTester tester,
  ) async {
    var historyTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoDrawer(
            onWorkspaceTap: () {},
            onMyIdentityTap: () {},
            onPairingHubTap: () {},
            onHistoryTap: () => historyTaps++,
            onSubscriptionTap: () {},
            onSecurityCenterTap: () {},
            onSettingsTap: () {},
            onAboutTap: () {},
            onLogoutTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Encrypted History'), findsNothing);
    expect(find.text('Decrypted History'), findsNothing);
    await tester.tap(find.text('History'));
    expect(historyTaps, 1);
  });
}
