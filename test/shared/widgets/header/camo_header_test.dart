import 'package:camo/core/theme/camo_colors.dart';
import 'package:camo/shared/widgets/header/camo_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compact header preserves CAMO and approved actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var pair = 0;
    var identity = 0;
    var scans = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoHeader(
            onMenuTap: () {},
            onPairRequestsTap: () => pair++,
            onNotificationsTap: () {},
            onScanQrTap: () => scans++,
            onIdentityTap: () => identity++,
            pairRequestsCount: 3,
          ),
        ),
      ),
    );
    expect(find.text('CAMO'), findsOneWidget);
    final camoTitle = tester.widget<Text>(find.text('CAMO'));
    expect(camoTitle.style?.color, CamoColors.primary);
    final menuIcon = tester.widget<Icon>(
      find.descendant(of: find.byTooltip('Menu'), matching: find.byType(Icon)),
    );
    expect(menuIcon.color, CamoColors.primary);
    final pairIcon = tester.widget<Icon>(
      find.descendant(
        of: find.byTooltip('Pair Requests'),
        matching: find.byType(Icon),
      ),
    );
    expect(pairIcon.color, CamoColors.primary);
    expect(find.byIcon(Icons.person_add_alt_1_rounded), findsOneWidget);
    expect(find.byTooltip('Scan QR'), findsOneWidget);
    expect(find.byTooltip('Identity'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Pair Requests'));
    await tester.tap(find.byTooltip('Scan QR'));
    await tester.tap(find.byTooltip('Identity'));
    expect((pair, scans, identity), (1, 1, 1));
  });
}
