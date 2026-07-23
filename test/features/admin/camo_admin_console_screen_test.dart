import 'package:camo/features/admin/domain/entities/camo_admin_device.dart';
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

  @override
  Future<void> approveRequest({
    required String userId,
    required String requestId,
  }) async {
    if (shouldThrow) {
      throw StateError('failed');
    }
  }

  @override
  Future<void> rejectRequest({
    required String userId,
    required String requestId,
    required String reason,
  }) async {
    if (shouldThrow) {
      throw StateError('failed');
    }
  }

  @override
  Future<List<CamoAdminDevice>> fetchDevices(String userId) async {
    if (shouldThrow) {
      throw StateError('failed');
    }
    return const <CamoAdminDevice>[];
  }

  @override
  Future<void> replaceDevice({
    required String userId,
    required String requestId,
    required String previousDeviceId,
    required String reason,
  }) async {
    if (shouldThrow) {
      throw StateError('failed');
    }
  }
}

void main() {
  Widget buildSubject(CamoAdminDeviceRequestRepository repository) {
    return MaterialApp(
      home: CamoAdminConsoleScreen(
        activeCommercialAccessPanel: const SizedBox.shrink(),
        pendingCommercialRequestsPanel: const Text('Commercial Access'),
        deviceRequestRepository: repository,
      ),
    );
  }

  testWidgets('preserves enterprise layout for live empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject(const _FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Admin Console'), findsOneWidget);
    expect(find.text('Authorized admin session'), findsOneWidget);
    expect(find.text('Pending requests'), findsOneWidget);
    expect(find.text('Visible results'), findsOneWidget);
    expect(find.text('Loaded records'), findsOneWidget);
    expect(find.text('Search requests'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('No pending device requests'), findsOneWidget);
    expect(
      find.text('There are no live requests awaiting action.'),
      findsOneWidget,
    );
    expect(find.text('Commercial Access'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Deferred secure modules'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Deferred secure modules'), findsOneWidget);
    expect(find.text('Audit History'), findsOneWidget);
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('shows live actions while preserving search and statistics', (
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
    expect(find.text('User: person@example.com'), findsOneWidget);
    expect(find.text('User ID: user-1'), findsOneWidget);
    expect(find.text('Device ID: device-1'), findsOneWidget);
    expect(find.text('Platform: web'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    expect(find.text('Active Devices'), findsOneWidget);
    expect(find.text('Device Replacement'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();

    expect(find.text('No matching requests'), findsOneWidget);
    expect(find.text('Visible results'), findsOneWidget);
  });

  testWidgets('shows fail-closed live-load error and retry state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const _FakeRepository(shouldThrow: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin data unavailable'), findsOneWidget);
    expect(
      find.text('Unable to load live pending device requests.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
