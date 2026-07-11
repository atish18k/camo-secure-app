// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/shared/types/camo_device_trust_level.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_risk_level.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CAMO shared security types', () {
    test('operation type exposes stable wire name', () {
      expect(CamoOperationType.registerDevice.wireName, 'register_device');
      expect(CamoOperationType.decode.wireName, 'decode');
    });
    test('security decision exposes authorization state', () {
      expect(CamoSecurityDecision.allow.isAllowed, isTrue);
      expect(CamoSecurityDecision.deny.isDenied, isTrue);
      expect(CamoSecurityDecision.stepUpRequired.requiresStepUp, isTrue);
    });
    test('risk and device trust enforce secure defaults', () {
      expect(CamoRiskLevel.high.blocksSensitiveOperation, isTrue);
      expect(CamoRiskLevel.medium.blocksSensitiveOperation, isFalse);
      expect(CamoDeviceTrustLevel.trusted.permitsSensitiveOperation, isTrue);
      expect(CamoDeviceTrustLevel.unknown.permitsSensitiveOperation, isFalse);
      expect(CamoDeviceTrustLevel.revoked.isBlocked, isTrue);
    });
  });
}
