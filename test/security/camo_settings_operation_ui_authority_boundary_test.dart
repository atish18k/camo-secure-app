import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings remains fail closed and protected', () {
    final settings = File(
      'lib/features/settings/presentation/screens/camo_settings_screen.dart',
    ).readAsStringSync();
    final routes = File('lib/app/routes.dart').readAsStringSync();
    expect(settings, isNot(contains('FirebaseFirestore')));
    expect(settings, isNot(contains('SecureStorageService')));
    expect(settings, isNot(contains('AppRoutes.myIdentity')));
    expect(settings, isNot(contains('AppRoutes.recoverySetup')));
    expect(
      routes,
      contains('settings: (context) => protect(const CamoSettingsScreen())'),
    );
  });
}
