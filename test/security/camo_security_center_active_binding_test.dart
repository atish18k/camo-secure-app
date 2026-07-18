import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active drawer opens protected live Security Center route', () {
    final routes = File('lib/app/routes.dart').readAsStringSync();
    final workspace = File(
      'lib/features/workspace/presentation/screens/workspace_screen.dart',
    ).readAsStringSync();
    final screen = File(
      'lib/features/dashboard/presentation/screens/security_center_screen.dart',
    ).readAsStringSync();
    final card = File(
      'lib/features/dashboard/presentation/widgets/security_center_card.dart',
    ).readAsStringSync();

    expect(routes, contains("securityCenter = '/security-center'"));
    expect(routes, contains('protect(const SecurityCenterScreen())'));
    expect(workspace, contains('onSecurityCenterTap: _openSecurityCenter'));
    expect(
      workspace,
      contains('Navigator.pushNamed(context, AppRoutes.securityCenter)'),
    );
    expect(
      workspace,
      isNot(contains('onSecurityCenterTap: _closeDrawerAndShowComingSoon')),
    );
    expect(screen, contains('SecurityCenterCard()'));
    expect(card, contains('ensureTrusted()'));
    expect(card, contains('Exact device'));
    expect(card, contains('Key binding'));
    expect(card, contains('Revocation'));
  });
}
