import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workspace visibility is fresh-token driven and fail closed', () {
    final String workspace = File(
      'lib/features/workspace/presentation/screens/workspace_screen.dart',
    ).readAsStringSync();

    expect(workspace, contains('bool _showAdminConsole = false;'));
    expect(workspace, contains('FirebaseCamoAdminAccessService'));
    expect(workspace, contains('.hasFreshAdminAccess()'));
    expect(
      workspace,
      contains('final bool allowed = await FirebaseCamoAdminAccessService()'),
    );
    expect(workspace, contains('showAdminConsole: _showAdminConsole'));
    expect(workspace, contains('onAdminConsoleTap: _openAdminConsole'));
    expect(
      workspace,
      contains('Navigator.pushNamed(context, AppRoutes.adminConsole)'),
    );
  });

  test('drawer keeps Admin Console conditional and logout independent', () {
    final String drawer = File(
      'lib/shared/widgets/navigation/camo_drawer.dart',
    ).readAsStringSync();

    expect(drawer, contains('this.showAdminConsole = false'));
    expect(drawer, contains('final bool showAdminConsole;'));
    expect(drawer, contains('if (showAdminConsole)'));
    expect(drawer, contains("title: 'Admin Console'"));
    expect(drawer, contains("title: 'Logout'"));

    final int admin = drawer.indexOf("title: 'Admin Console'");
    final int logout = drawer.indexOf("title: 'Logout'");

    expect(admin, greaterThanOrEqualTo(0));
    expect(logout, greaterThan(admin));
  });

  test('Admin Console route remains outside ordinary device gate', () {
    final String routes = File('lib/app/routes.dart').readAsStringSync();

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
}
