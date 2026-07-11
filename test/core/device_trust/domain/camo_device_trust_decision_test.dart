// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/device_trust/domain/entities/camo_device_trust_decision.dart';
import 'package:camo/core/shared/types/camo_device_trust_level.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoDeviceTrustDecision', () {
    test('valid trusted decision permits operation', () {
      final DateTime now = DateTime.now();
      final CamoDeviceTrustDecision decision = CamoDeviceTrustDecision(
        deviceId: 'device-001',
        trustLevel: CamoDeviceTrustLevel.trusted,
        allowed: true,
        reasonCode: 'trusted_device',
        evaluatedAt: now,
        expiresAt: now.add(const Duration(minutes: 1)),
      );
      expect(decision.permitsOperation, isTrue);
      expect(decision.isExpired, isFalse);
    });
    test('expired decision denies operation', () {
      final DateTime now = DateTime.now();
      final CamoDeviceTrustDecision decision = CamoDeviceTrustDecision(
        deviceId: 'device-001',
        trustLevel: CamoDeviceTrustLevel.trusted,
        allowed: true,
        reasonCode: 'trusted_device',
        evaluatedAt: now.subtract(const Duration(minutes: 2)),
        expiresAt: now.subtract(const Duration(minutes: 1)),
      );
      expect(decision.permitsOperation, isFalse);
      expect(decision.isExpired, isTrue);
    });
  });
}
