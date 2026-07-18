import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recovery UI has no provider, storage or client authority binding', () {
    final String screen = File(
      'lib/features/recovery/presentation/screens/recovery_setup_screen.dart',
    ).readAsStringSync();
    final String state = File(
      'lib/features/recovery/presentation/models/camo_recovery_view_state.dart',
    ).readAsStringSync();

    expect(screen, isNot(contains('FirebaseFirestore')));
    expect(screen, isNot(contains('SecureStorageService')));
    expect(screen, isNot(contains('GoogleSignIn')));
    expect(screen, isNot(contains('privateKey')));
    expect(screen, isNot(contains('seedPhrase')));
    expect(screen, contains('Consent does not create a backup'));
    expect(screen, contains('require separate server authorization'));
    expect(state, contains('CamoRecoveryViewState.unbound'));
    expect(state, contains('encryptedBackupAvailable = false'));
    expect(state, contains('deviceLossRecoveryAvailable = false'));
  });

  test('recovery route is protected and visible from Security Center', () {
    final String routes = File('lib/app/routes.dart').readAsStringSync();
    final String securityCenter = File(
      'lib/features/dashboard/presentation/screens/security_center_screen.dart',
    ).readAsStringSync();

    expect(
      routes,
      contains(
        'recoverySetup: (context) => protect(const RecoverySetupScreen())',
      ),
    );
    expect(securityCenter, contains('AppRoutes.recoverySetup'));
  });
}
