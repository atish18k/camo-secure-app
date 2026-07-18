import 'package:camo/shared/widgets/navigation/camo_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drawer retires identity duplicate', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoDrawer(
            onWorkspaceTap: () {},
            onPairingHubTap: () {},
            onHistoryTap: () {},
            onSubscriptionTap: () {},
            onSecurityCenterTap: () {},
            onSettingsTap: () {},
            onAboutTap: () {},
            onLogoutTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('My Identity'), findsNothing);
    expect(find.text('Security Center'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
