import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camo/features/admin/domain/repositories/'
    'camo_admin_commercial_request_repository.dart';
import 'package:camo/features/admin/presentation/widgets/'
    'camo_admin_pending_commercial_requests_panel.dart';

final class _FakeCommercialRequestRepository
    implements CamoAdminCommercialRequestRepository {
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

  final List<int> approvedDurations = <int>[];
  final List<String> approvedRequestIds = <String>[];

  @override
  Future<List<CamoPendingCommercialRequest>> listPendingRequests() async {
    return <CamoPendingCommercialRequest>[
      CamoPendingCommercialRequest(
        requestId: 'user-001',
        userId: 'user-001',
        userEmail: 'user@example.com',
        status: 'pending',
        requestedAt: DateTime.utc(2026, 7, 23),
      ),
    ];
  }

  @override
  Future<CamoApprovedCommercialRequest> approveRequest({
    required String requestId,
    required int durationDays,
  }) async {
    approvedRequestIds.add(requestId);
    approvedDurations.add(durationDays);

    return CamoApprovedCommercialRequest(
      requestId: requestId,
      userId: 'user-001',
      durationDays: durationDays,
      expiresAt: DateTime.utc(2026, 7, 26),
      auditEventId: 'audit-001',
    );
  }
}

void main() {
  testWidgets('pending commercial request exposes fixed duration and Approve', (
    WidgetTester tester,
  ) async {
    final _FakeCommercialRequestRepository repository =
        _FakeCommercialRequestRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoAdminPendingCommercialRequestsPanel(repository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pending Commercial Access Requests'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsNothing);
    expect(find.byType(TextField), findsNothing);

    final Finder dropdown = find.byKey(
      const Key('commercial-duration-user-001'),
    );
    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.text('1 day(s)'), findsWidgets);
    expect(find.text('3 day(s)'), findsOneWidget);
    expect(find.text('7 day(s)'), findsOneWidget);
    expect(find.text('10 day(s)'), findsOneWidget);

    await tester.tap(find.text('3 day(s)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('approve-commercial-user-001')));
    await tester.pumpAndSettle();

    expect(find.text('Approve Commercial Access?'), findsOneWidget);
    expect(find.textContaining('for 3 day(s)?'), findsOneWidget);

    final Finder dialogApproveButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Approve'),
    );
    expect(dialogApproveButton, findsOneWidget);

    await tester.tap(dialogApproveButton);
    await tester.pumpAndSettle();

    expect(repository.approvedRequestIds, <String>['user-001']);
    expect(repository.approvedDurations, <int>[3]);
    expect(find.text('user@example.com'), findsNothing);
    expect(
      find.textContaining('Access approved for 3 day(s).'),
      findsOneWidget,
    );
  });
}
