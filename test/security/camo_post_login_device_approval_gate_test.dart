import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all functional routes are protected by the device approval gate', () {
    final routes = File('lib/app/routes.dart').readAsStringSync();
    final app = File('lib/app/app.dart').readAsStringSync();
    final gate = File(
      'lib/features/policy/presentation/screens/camo_device_approval_gate.dart',
    ).readAsStringSync();
    final login = File(
      'lib/features/auth/domain/usecases/login_usecase.dart',
    ).readAsStringSync();

    for (final route in <String>[
      'home:',
      'workspace:',
      'dashboard:',
      'pairRequest:',
      'pendingPairRequests:',
      'qrScanner:',
    ]) {
      expect(routes, contains(route));
    }
    expect(
      RegExp(r'protect\(const WorkspaceScreen\(\)\)').allMatches(routes).length,
      3,
    );
    expect(routes, contains('protect(const PairRequestScreen())'));
    expect(routes, contains('protect(const PendingPairRequestsScreen())'));
    expect(routes, contains('protect(const QrScannerScreen())'));
    expect(app, contains('AppRoutes.protect(const MyIdentityScreen())'));
    expect(app, contains('AppRoutes.protect(const PairingHubScreen())'));
    expect(gate, contains('ensureTrusted()'));
    expect(gate, contains('Device approval pending'));
    expect(gate, contains('Check approval again'));
    expect(gate, contains('Logout'));
    expect(login, isNot(contains('CAMO-LOCAL-DEVICE-APPROVAL-HARNESS')));
    expect(login, isNot(contains('approveDeviceRegistrationRequest')));
  });
}
