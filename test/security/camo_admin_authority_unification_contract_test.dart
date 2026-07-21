import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('camoAdmin is the only executable device-approval admin claim', () {
    final String backend = File('functions/src/index.ts').readAsStringSync();

    expect(backend, contains('request.auth.token.camoAdmin !== true'));
    expect(backend, contains('CAMO admin role is required.'));
    expect(backend, isNot(contains('camoDeviceApprover')));
  });

  test(
    'admin access is locked to the exact configured identity and fresh claim',
    () {
      final String service = File(
        'lib/features/admin/data/services/'
        'firebase_camo_admin_access_service.dart',
      ).readAsStringSync();

      expect(
        service,
        contains("expectedAdminUid = 'VSgby7BHaRd1MFplKsBAd2QmV9Z2'"),
      );
      expect(service, contains("expectedAdminEmail = 'atish18k@gmail.com'"));
      expect(service, contains('actualUid != lockedUid'));
      expect(service, contains('actualEmail != lockedEmail'));
      expect(service, contains('getIdTokenResult(true)'));
      expect(service, contains("token.claims?['camoAdmin'] == true"));
      expect(service, contains('catch (_)'));
      expect(service, isNot(contains('camoDeviceApprover')));
    },
  );

  test('authorized admin route remains outside ordinary device binding', () {
    final String resolver = File(
      'lib/features/admin/presentation/screens/'
      'camo_post_login_route_resolver.dart',
    ).readAsStringSync();
    final String routes = File('lib/app/routes.dart').readAsStringSync();

    expect(resolver, contains('.hasFreshAdminAccess()'));
    expect(
      resolver,
      contains('isAdmin ? AppRoutes.adminConsole : AppRoutes.dashboard'),
    );
    expect(
      routes,
      contains('adminConsole: (context) => const CamoAdminConsoleGate()'),
    );
    expect(routes, isNot(contains('adminConsole: (context) => protect(')));
    expect(
      routes,
      contains('dashboard: (context) => protect(const WorkspaceScreen())'),
    );
  });

  test('ordinary protected routes remain device and composite gated', () {
    final String routes = File('lib/app/routes.dart').readAsStringSync();

    expect(routes, contains('CamoDeviceApprovalGate('));
    expect(routes, contains('CamoCompositeAccessGate('));
    expect(routes, contains('child: child'));
  });
}
