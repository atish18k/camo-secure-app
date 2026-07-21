import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 1 Admin Console remains read only and fail closed', () {
    final String screen = File(
      'lib/features/admin/presentation/screens/'
      'camo_admin_console_screen.dart',
    ).readAsStringSync();

    final String placeholder = File(
      'lib/features/admin/data/repositories/'
      'placeholder_camo_admin_device_request_repository.dart',
    ).readAsStringSync();

    expect(screen, contains('Approval actions not connected'));
    expect(screen, contains('server-authorized and audited endpoint'));
    expect(screen, contains('Unable to load admin data'));
    expect(screen, contains('No privileged action was performed'));

    expect(screen, isNot(contains('approveDeviceRegistrationRequest')));
    expect(screen, isNot(contains('FirebaseFunctions.instance')));
    expect(screen, isNot(contains('FirebaseFirestore.instance')));
    expect(screen, isNot(contains('setCustomUserClaims')));
    expect(screen, isNot(contains('Commercial Access granted')));

    expect(placeholder, contains('return const <CamoAdminDeviceRequest>[];'));
  });

  test('Phase 1 exposes search, filter, refresh, empty and retry states', () {
    final String screen = File(
      'lib/features/admin/presentation/screens/'
      'camo_admin_console_screen.dart',
    ).readAsStringSync();

    expect(screen, contains("labelText: 'Search requests'"));
    expect(screen, contains('SegmentedButton<_AdminRequestFilter>'));
    expect(screen, contains("tooltip: 'Refresh'"));
    expect(screen, contains("title: 'No pending device requests'"));
    expect(screen, contains("title: 'No matching requests'"));
    expect(screen, contains("label: const Text('Retry')"));
  });
}
