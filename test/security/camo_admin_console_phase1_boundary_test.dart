import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Admin Console is no longer a Phase 1 placeholder', () {
    final String screen = File(
      'lib/features/admin/presentation/screens/camo_admin_console_screen.dart',
    ).readAsStringSync();
    expect(screen, contains('FirebaseCamoAdminDeviceRepository'));
    expect(screen, contains('Live server-authorized device administration'));
    expect(screen, isNot(contains('Phase 1 UI is ready')));
  });
}
