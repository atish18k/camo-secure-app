import 'package:camo/features/notifications/data/repositories/unbound_camo_notification_repository.dart';
import 'package:camo/features/notifications/presentation/providers/other_notifications_provider.dart';
import 'package:camo/features/notifications/presentation/screens/other_notifications_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unbound panel communicates honest unavailable state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          otherNotificationsRepositoryProvider.overrideWithValue(
            const UnboundCamoNotificationRepository(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: OtherNotificationsPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Notifications not connected'), findsOneWidget);
    expect(find.textContaining('secure service is connected'), findsOneWidget);
  });
}
