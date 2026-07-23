import 'package:camo/features/admin/domain/repositories/camo_admin_commercial_request_repository.dart';
import 'package:camo/features/admin/presentation/widgets/camo_admin_pending_commercial_requests_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements CamoAdminCommercialRequestRepository {
  @override
  Future<List<CamoActiveCommercialAccess>> listActiveAccess() async {
    return const <CamoActiveCommercialAccess>[];
  }

  @override
  Future<CamoRevokedCommercialAccess> revokeAccess({required String userId}) {
    throw UnimplementedError(
      'Pending commercial request tests do not exercise revoke access.',
    );
  }

  int? approvedDays;
  String? approvedRequestId;

  @override
  Future<List<CamoPendingCommercialRequest>> listPendingRequests() async {
    return <CamoPendingCommercialRequest>[
      CamoPendingCommercialRequest(
        requestId: 'user-123',
        userId: 'user-123',
        userEmail: 'user@example.com',
        status: 'pending',
        requestedAt: DateTime.utc(2026, 7, 22),
      ),
    ];
  }

  @override
  Future<CamoApprovedCommercialRequest> approveRequest({
    required String requestId,
    required int durationDays,
  }) async {
    approvedRequestId = requestId;
    approvedDays = durationDays;
    return CamoApprovedCommercialRequest(
      requestId: requestId,
      userId: requestId,
      durationDays: durationDays,
      expiresAt: DateTime.utc(2026, 7, 29),
      auditEventId: 'audit-1',
    );
  }
}

void main() {
  testWidgets('shows pending request with only duration and approve controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoAdminPendingCommercialRequestsPanel(
            repository: _FakeRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pending Commercial Access Requests'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.byType(DropdownButton<int>), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Camouflage'), findsNothing);
    expect(find.textContaining('Device'), findsNothing);
    expect(find.textContaining('Reason'), findsNothing);
  });

  testWidgets('approves selected request for selected duration', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoAdminPendingCommercialRequestsPanel(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 day(s)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve').last);
    await tester.pumpAndSettle();

    expect(repository.approvedRequestId, 'user-123');
    expect(repository.approvedDays, 7);
    expect(find.text('No pending commercial access requests.'), findsOneWidget);
  });
}
