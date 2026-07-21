import 'package:camo/features/admin/domain/entities/camo_admin_device_request.dart';
import 'package:camo/features/admin/domain/repositories/camo_admin_device_request_repository.dart';
import 'package:camo/features/admin/presentation/screens/camo_admin_console_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements CamoAdminDeviceRequestRepository {
  const _FakeRepository({
    this.requests = const <CamoAdminDeviceRequest>[],
    this.shouldThrow = false,
  });

  final List<CamoAdminDeviceRequest> requests;
  final bool shouldThrow;

  @override
  Future<List<CamoAdminDeviceRequest>> fetchPendingRequests() async {
    if (shouldThrow) {
      throw StateError('failed');
    }
    return requests;
  }
}

void main() {
  Widget buildSubject(CamoAdminDeviceRequestRepository repository) {
    return MaterialApp(
      home: CamoAdminConsoleScreen(deviceRequestRepository: repository),
    );
  }

  testWidgets('shows Phase 1 empty state without privileged writes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject(const _FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Admin Console'), findsOneWidget);
    expect(find.text('No pending device requests'), findsOneWidget);
    expect(find.text('Approval actions not connected'), findsNothing);
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('shows pending request and supports search', (
    WidgetTester tester,
  ) async {
    final CamoAdminDeviceRequest request = CamoAdminDeviceRequest(
      requestId: 'request-1',
      userId: 'user-1',
      userEmail: 'person@example.com',
      deviceId: 'device-1',
      deviceLabel: 'Chrome Windows',
      platform: 'web',
      requestedAt: DateTime.utc(2026, 7, 21),
      status: CamoAdminDeviceRequestStatus.pending,
    );

    await tester.pumpWidget(
      buildSubject(
        _FakeRepository(requests: <CamoAdminDeviceRequest>[request]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chrome Windows'), findsOneWidget);
    expect(find.textContaining('person@example.com'), findsOneWidget);
    expect(find.text('Approval actions not connected'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();

    expect(find.text('No matching requests'), findsOneWidget);
  });

  testWidgets('shows fail-closed error and retry state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const _FakeRepository(shouldThrow: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin data unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(
      find.textContaining('No privileged action was performed'),
      findsOneWidget,
    );
  });
}
