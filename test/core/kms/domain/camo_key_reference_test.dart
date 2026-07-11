// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_reference.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/kms/domain/entities/camo_key_status.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoKeyReference', () {
    test('active unexpired key is usable', () {
      final CamoKeyReference reference = CamoKeyReference(
        keyId: 'key-001',
        keyVersion: '1',
        provider: 'cloud-kms',
        purpose: CamoKeyPurpose.messageEncryption,
        scope: CamoKeyScope.message,
        status: CamoKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      expect(reference.isUsable, isTrue);
      expect(reference.isExpired, isFalse);
    });
    test('revoked key is not usable', () {
      final CamoKeyReference reference = CamoKeyReference(
        keyId: 'key-002',
        keyVersion: '1',
        provider: 'cloud-kms',
        purpose: CamoKeyPurpose.messageDecryption,
        scope: CamoKeyScope.message,
        status: CamoKeyStatus.revoked,
        createdAt: DateTime.now(),
      );
      expect(reference.isUsable, isFalse);
    });
  });
}
