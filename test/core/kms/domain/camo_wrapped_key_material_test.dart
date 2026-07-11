// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/kms/domain/entities/camo_wrapped_key_material.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('device-bound unexpired wrapped key is usable', () {
    final DateTime now = DateTime.now();
    final CamoWrappedKeyMaterial material = CamoWrappedKeyMaterial(
      releaseId: 'release-001',
      keyId: 'key-001',
      wrappedKey: 'wrapped-key-material',
      wrappingAlgorithm: 'x25519-hkdf-aes-gcm',
      deviceId: 'device-001',
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
    );
    expect(material.isBoundToDevice, isTrue);
    expect(material.isUsable, isTrue);
  });
}
