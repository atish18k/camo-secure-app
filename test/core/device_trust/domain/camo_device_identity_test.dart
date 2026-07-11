// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/device_trust/domain/entities/camo_device_identity.dart';
import 'package:camo/core/device_trust/domain/entities/camo_device_status.dart';
import 'package:camo/core/shared/types/camo_device_trust_level.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoDeviceIdentity', () {
    test('approved trusted device permits sensitive operation', () {
      final CamoDeviceIdentity device = CamoDeviceIdentity(
        deviceId: 'device-001',
        userId: 'user-001',
        platform: 'android',
        publicKey: 'public-key',
        status: CamoDeviceStatus.approved,
        trustLevel: CamoDeviceTrustLevel.trusted,
        registeredAt: DateTime.utc(2026, 7, 11),
        approvedAt: DateTime.utc(2026, 7, 11),
      );
      expect(device.permitsSensitiveOperation, isTrue);
      expect(device.isBlocked, isFalse);
    });
    test('revoked device is blocked', () {
      final CamoDeviceIdentity device = CamoDeviceIdentity(
        deviceId: 'device-002',
        userId: 'user-001',
        platform: 'android',
        publicKey: 'public-key',
        status: CamoDeviceStatus.revoked,
        trustLevel: CamoDeviceTrustLevel.revoked,
        registeredAt: DateTime.utc(2026, 7, 11),
        revokedAt: DateTime.utc(2026, 7, 11),
      );
      expect(device.permitsSensitiveOperation, isFalse);
      expect(device.isBlocked, isTrue);
    });
  });
}
