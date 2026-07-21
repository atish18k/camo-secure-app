import 'package:camo/shared/widgets/navigation/camo_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildDrawer({
    required bool showAdminConsole,
    VoidCallback? onAdminConsoleTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        drawer: CamoDrawer(
          onWorkspaceTap: () {},
          onPairingHubTap: () {},
          onHistoryTap: () {},
          onSubscriptionTap: () {},
          onSecurityCenterTap: () {},
          onSettingsTap: () {},
          onAboutTap: () {},
          onLogoutTap: () {},
          showAdminConsole: showAdminConsole,
          onAdminConsoleTap: onAdminConsoleTap,
        ),
        body: const SizedBox(),
      ),
    );
  }

  testWidgets('Admin Console is hidden by default', (tester) async {
    await tester.pumpWidget(buildDrawer(showAdminConsole: false));

    final ScaffoldState state = tester.state(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Admin Console'), findsNothing);
  });

  testWidgets('verified admin can see and invoke Admin Console item', (
    tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      buildDrawer(
        showAdminConsole: true,
        onAdminConsoleTap: () {
          tapped = true;
        },
      ),
    );

    final ScaffoldState state = tester.state(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    final Finder adminConsoleItem = find.text('Admin Console');

    await tester.scrollUntilVisible(
      adminConsoleItem,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(adminConsoleItem, findsOneWidget);

    await tester.tap(adminConsoleItem);
    await tester.pump();

    expect(tapped, isTrue);
  });
}
