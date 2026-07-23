import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commercial approval UI is duration plus Approve only', () {
    final String panel = File(
      'lib/features/admin/presentation/widgets/'
      'camo_admin_pending_commercial_requests_panel.dart',
    ).readAsStringSync();
    final String repository = File(
      'lib/features/admin/data/repositories/'
      'firebase_camo_admin_commercial_request_repository.dart',
    ).readAsStringSync();

    final int approvalRepositoryStart = repository.indexOf(
      'Future<CamoApprovedCommercialRequest> approveRequest',
    );
    final int activeAccessRepositoryStart = repository.indexOf(
      'Future<List<CamoActiveCommercialAccess>> listActiveAccess',
      approvalRepositoryStart,
    );

    expect(approvalRepositoryStart, greaterThanOrEqualTo(0));
    expect(activeAccessRepositoryStart, greaterThan(approvalRepositoryStart));

    final String approvalRepository = repository.substring(
      approvalRepositoryStart,
      activeAccessRepositoryStart,
    );
    final String backend = File('functions/src/index.ts').readAsStringSync();

    expect(
      panel,
      contains('static const List<int> _durations = <int>[1, 3, 7, 10];'),
    );
    expect(panel, contains("label: const Text('Approve')"));
    expect(panel, isNot(contains("label: const Text('Reject')")));
    expect(panel, isNot(contains('TextField(')));
    expect(panel, isNot(contains('deviceAllowance')));
    expect(panel, isNot(contains('grantedEntitlements')));
    expect(panel, isNot(contains('Administrative Reason')));
    expect(panel.toLowerCase(), isNot(contains('camouflage')));

    expect(
      repository,
      contains("httpsCallable('approveCommercialAccessRequest')"),
    );
    expect(
      repository,
      contains("{'requestId': requestId, 'durationDays': durationDays}"),
    );
    expect(approvalRepository, isNot(contains("'userId':")));
    expect(approvalRepository, isNot(contains("'reason':")));
    expect(approvalRepository, isNot(contains("'deviceAllowance':")));
    expect(approvalRepository, isNot(contains("'grantedEntitlements':")));

    expect(
      backend,
      contains(
        'const allowedCommercialApprovalDurations = '
        'new Set<number>([1, 3, 7, 10]);',
      ),
    );
    expect(backend, contains('const adminUid = assertLockedAdmin(request);'));
    expect(backend, contains('pending.userId !== requestId'));
    expect(backend, contains('deviceAllowance: 1'));
    expect(
      backend,
      contains('grantedEntitlements: ["baseEncoding", "baseDecoding"]'),
    );
  });

  test('approval target is resolved from pending request, not client UID', () {
    final String backend = File('functions/src/index.ts').readAsStringSync();

    final int approvalStart = backend.indexOf(
      'export const approveCommercialAccessRequest = onCall',
    );
    final int nextCallableStart = backend.indexOf(
      'export const listActiveCommercialAccess = onCall',
      approvalStart,
    );

    expect(approvalStart, greaterThanOrEqualTo(0));
    expect(nextCallableStart, greaterThan(approvalStart));

    final String approvalHandler = backend.substring(
      approvalStart,
      nextCallableStart,
    );

    expect(approvalHandler, contains('.doc(requestId)'));
    expect(approvalHandler, contains('.doc(pending.userId)'));
    expect(approvalHandler, isNot(contains('payload.userId')));
    expect(approvalHandler, isNot(contains('payload.deviceAllowance')));
    expect(approvalHandler, isNot(contains('payload.grantedEntitlements')));
    expect(approvalHandler, isNot(contains('payload.reason')));
  });
}
