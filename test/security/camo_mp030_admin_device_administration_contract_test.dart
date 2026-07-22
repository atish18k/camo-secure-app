import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MP-030 uses live callable-backed device administration', () {
    final String backend = File('functions/src/index.ts').readAsStringSync();
    final String service = File(
      'functions/src/services/admin_device_administration_service.ts',
    ).readAsStringSync();
    final String repository = File(
      'lib/features/admin/data/repositories/firebase_camo_admin_device_repository.dart',
    ).readAsStringSync();
    final String screen = File(
      'lib/features/admin/presentation/screens/camo_admin_console_screen.dart',
    ).readAsStringSync();

    expect(backend, contains('listPendingDeviceRegistrationRequests'));
    expect(backend, contains('rejectDeviceRegistrationRequest'));
    expect(backend, contains('listAdminUserDevices'));
    expect(backend, contains('replaceApprovedDevice'));
    expect(backend, contains('assertLockedAdmin'));
    expect(service, contains('adminAuditEvents'));
    expect(service, contains('device_replaced'));
    expect(service, contains('status: "revoked"'));
    expect(repository, contains('FirebaseCamoAdminDeviceRepository'));
    expect(repository, contains('httpsCallable'));
    expect(screen, contains('Approve'));
    expect(screen, contains('Reject'));
    expect(screen, contains('Active Devices'));
    expect(screen, contains('Device Replacement'));
    expect(
      screen,
      isNot(contains('PlaceholderCamoAdminDeviceRequestRepository')),
    );
  });

  test('MP-030C commercial mutation is not mixed into MP-030', () {
    final String screen = File(
      'lib/features/admin/presentation/screens/camo_admin_console_screen.dart',
    ).readAsStringSync();
    expect(screen, contains('MP-030C remains separately bounded'));
    expect(screen, isNot(contains('Commercial Access granted')));
  });
}
