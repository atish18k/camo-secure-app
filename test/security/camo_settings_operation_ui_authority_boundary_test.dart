import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'settings and operation UI add no client authority or provider binding',
    () {
      final settings = File(
        'lib/features/settings/presentation/screens/camo_settings_screen.dart',
      ).readAsStringSync();
      final banner = File(
        'lib/features/workspace/presentation/widgets/camo_workspace_operation_banner.dart',
      ).readAsStringSync();
      expect(settings, isNot(contains('FirebaseFirestore')));
      expect(settings, isNot(contains('SecureStorageService')));
      expect(settings, isNot(contains('GoogleSignIn')));
      expect(settings, isNot(contains('privateKey')));
      expect(settings, contains('Encrypted restore unavailable'));
      expect(settings, contains('Secret export'));
      expect(banner, contains('liveRegion: true'));
    },
  );

  test('settings route is protected and drawer entry is bound', () {
    final routes = File('lib/app/routes.dart').readAsStringSync();
    final workspace = File(
      'lib/features/workspace/presentation/screens/workspace_screen.dart',
    ).readAsStringSync();
    expect(
      routes,
      contains('settings: (context) => protect(const CamoSettingsScreen())'),
    );
    expect(workspace, contains('onSettingsTap: _openSettings'));
    expect(workspace, contains('AppRoutes.settings'));
  });
}
