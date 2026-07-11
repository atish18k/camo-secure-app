// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_reference.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_decision.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/kms/domain/entities/camo_key_status.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoKeyReleaseDecision', () {
    test('valid allowed decision permits key release', () {
      final DateTime now = DateTime.now();
      final CamoKeyReleaseDecision decision = CamoKeyReleaseDecision(
        releaseId: 'release-001',
        authorizationId: 'authorization-001',
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'key_release_allowed',
        keyReference: CamoKeyReference(
          keyId: 'key-001',
          keyVersion: '1',
          provider: 'cloud-kms',
          purpose: CamoKeyPurpose.messageDecryption,
          scope: CamoKeyScope.message,
          status: CamoKeyStatus.active,
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 1)),
        ),
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        singleUse: true,
      );
      expect(decision.permitsKeyRelease, isTrue);
      expect(decision.singleUse, isTrue);
    });
  });
}
