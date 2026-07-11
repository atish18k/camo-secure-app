// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/policy_engine/domain/entities/camo_policy_evaluation_context.dart';
import 'package:camo/core/shared/types/camo_device_trust_level.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_risk_level.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoPolicyEvaluationContext', () {
    test('valid context exposes all security groups as valid', () {
      final CamoPolicyEvaluationContext context = CamoPolicyEvaluationContext(
        operationId: 'operation-001',
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.encode,
        deviceTrustLevel: CamoDeviceTrustLevel.trusted,
        riskLevel: CamoRiskLevel.low,
        sessionValid: true,
        pairValid: true,
        licenseValid: true,
        subscriptionValid: true,
        entitlementValid: true,
        messageValid: true,
        evaluatedAt: DateTime.utc(2026, 7, 11),
      );
      expect(context.hasValidIdentityContext, isTrue);
      expect(context.hasValidCommercialContext, isTrue);
      expect(context.hasValidOperationContext, isTrue);
    });
    test('invalid subscription fails commercial context', () {
      final CamoPolicyEvaluationContext context = CamoPolicyEvaluationContext(
        operationId: 'operation-002',
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.decode,
        deviceTrustLevel: CamoDeviceTrustLevel.trusted,
        riskLevel: CamoRiskLevel.low,
        sessionValid: true,
        pairValid: true,
        licenseValid: true,
        subscriptionValid: false,
        entitlementValid: true,
        messageValid: true,
        evaluatedAt: DateTime.utc(2026, 7, 11),
      );
      expect(context.hasValidCommercialContext, isFalse);
    });
  });
}
