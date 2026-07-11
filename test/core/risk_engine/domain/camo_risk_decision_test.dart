// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/risk_engine/domain/entities/camo_risk_decision.dart';
import 'package:camo/core/shared/types/camo_risk_level.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoRiskDecision', () {
    test('low-risk allowed decision permits operation', () {
      final DateTime now = DateTime.now();
      final CamoRiskDecision decision = CamoRiskDecision(
        decisionId: 'decision-001',
        riskLevel: CamoRiskLevel.low,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'risk_acceptable',
        score: 10,
        evaluatedAt: now,
        expiresAt: now.add(const Duration(minutes: 1)),
      );
      expect(decision.permitsOperation, isTrue);
    });
    test('high-risk decision blocks operation', () {
      final DateTime now = DateTime.now();
      final CamoRiskDecision decision = CamoRiskDecision(
        decisionId: 'decision-002',
        riskLevel: CamoRiskLevel.high,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'risk_high',
        score: 80,
        evaluatedAt: now,
        expiresAt: now.add(const Duration(minutes: 1)),
      );
      expect(decision.permitsOperation, isFalse);
    });
  });
}
