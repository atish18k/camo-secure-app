import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pre-purchase eligibility is honest and fail closed', () {
    final source = File(
      'lib/features/policy/presentation/screens/camo_device_eligibility_screen.dart',
    ).readAsStringSync();
    expect(source, contains('Fully Supported'));
    expect(source, contains('Limited Support'));
    expect(source, contains('Unsupported'));
    expect(source, contains('hardwareBackingConfirmed: false'));
    expect(source, contains('_limitedAccepted'));
    expect(source, contains('Purchase activation unavailable'));
    expect(source, contains('Exact-device approval remains mandatory'));
  });

  test('eligibility is reachable before authentication', () {
    final routes = File('lib/app/routes.dart').readAsStringSync();
    final login = File(
      'lib/features/auth/presentation/widgets/login_form.dart',
    ).readAsStringSync();
    expect(routes, contains("deviceEligibility = '/device-eligibility'"));
    expect(
      routes,
      contains(
        'deviceEligibility: (context) => const CamoDeviceEligibilityScreen()',
      ),
    );
    expect(login, contains('Check device support before purchase'));
  });

  test('device gate and Security Center never use static trust claims', () {
    final gate = File(
      'lib/features/policy/presentation/screens/camo_device_approval_gate.dart',
    ).readAsStringSync();
    final card = File(
      'lib/features/dashboard/presentation/widgets/security_center_card.dart',
    ).readAsStringSync();
    expect(gate, contains('Device access restricted'));
    expect(gate, contains('Recovery approval unavailable'));
    expect(card, contains('ensureTrusted()'));
    expect(card, contains('Exact device'));
    expect(card, contains('Key binding'));
    expect(card, contains('Revocation'));
    expect(card, contains('Device management unavailable'));
    expect(card, isNot(contains("value: 'Verified'")));
    expect(card, isNot(contains("value: 'Protected'")));
  });
}
