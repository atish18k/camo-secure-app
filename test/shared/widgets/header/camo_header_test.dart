import 'package:camo/shared/widgets/header/camo_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('header exposes the locked four actions and no legacy actions', (
    WidgetTester tester,
  ) async {
    var pairRequests = 0;
    var notifications = 0;
    var scans = 0;
    var identity = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoHeader(
            onMenuTap: () {},
            onPairRequestsTap: () => pairRequests++,
            onNotificationsTap: () => notifications++,
            onScanQrTap: () => scans++,
            onIdentityTap: () => identity++,
            pairRequestsCount: 3,
            notificationCount: 2,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pair Requests'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('Scan QR'), findsOneWidget);
    expect(find.byTooltip('Identity'), findsOneWidget);
    expect(find.byTooltip('Pair Request'), findsNothing);
    expect(find.byTooltip('Sent Requests'), findsNothing);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Pair Requests'));
    await tester.tap(find.byTooltip('Notifications'));
    await tester.tap(find.byTooltip('Scan QR'));
    await tester.tap(find.byTooltip('Identity'));
    expect(pairRequests, 1);
    expect(notifications, 1);
    expect(scans, 1);
    expect(identity, 1);
  });
}
