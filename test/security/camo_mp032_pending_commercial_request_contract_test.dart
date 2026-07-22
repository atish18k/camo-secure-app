import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin approval UI has no manual UID or advanced grant controls', () {
    final String panel = File(
      'lib/features/admin/presentation/widgets/'
      'camo_admin_pending_commercial_requests_panel.dart',
    ).readAsStringSync();
    final String repository = File(
      'lib/features/admin/data/repositories/'
      'firebase_camo_admin_commercial_request_repository.dart',
    ).readAsStringSync();
    final String backend = File('functions/src/index.ts').readAsStringSync();

    expect(panel, isNot(contains('TextField(')));
    expect(panel, isNot(contains('deviceAllowance')));
    expect(panel, isNot(contains('grantedEntitlements')));
    expect(panel, isNot(contains('camouflage')));
    expect(panel, isNot(contains('Administrative Reason')));
    expect(panel, contains('1, 3, 7, 10'));

    expect(
      repository,
      contains("httpsCallable('approveCommercialAccessRequest')"),
    );
    expect(repository, isNot(contains("'userId':")));
    expect(repository, isNot(contains("'reason':")));

    expect(backend, contains('const adminUid = assertLockedAdmin(request);'));
    expect(backend, contains('pending.userId !== requestId'));
    expect(
      backend,
      contains('grantedEntitlements: ["baseEncoding", "baseDecoding"]'),
    );
  });
}
