// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/policy_engine/domain/entities/camo_policy_decision.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_evaluation_context.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_rule_result.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_rule_status.dart';
import 'package:camo/core/policy_engine/domain/repositories/camo_policy_repository.dart';
import 'package:camo/core/policy_engine/domain/usecases/evaluate_camo_policy_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_device_trust_level.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_risk_level.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakePolicyRepository implements CamoPolicyRepository {
  @override
  Future<CamoResult<CamoPolicyDecision>> evaluatePolicy(
    CamoPolicyEvaluationContext context,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoPolicyDecision>(
      CamoPolicyDecision(
        decisionId: 'decision-001',
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'policy_allowed',
        policyVersion: '1',
        evaluatedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        ruleResults: const <CamoPolicyRuleResult>[
          CamoPolicyRuleResult(
            ruleId: 'device',
            status: CamoPolicyRuleStatus.passed,
            reasonCode: 'device_trusted',
            message: 'Device is trusted.',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('evaluate use case delegates to repository', () async {
    final EvaluateCamoPolicyUseCase useCase = EvaluateCamoPolicyUseCase(
      _FakePolicyRepository(),
    );
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
      evaluatedAt: DateTime.now(),
    );
    final CamoResult<CamoPolicyDecision> result = await useCase(context);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsOperation, isTrue);
  });
}
