// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/risk_engine/domain/entities/camo_risk_assessment_context.dart';
import 'package:camo/core/risk_engine/domain/entities/camo_risk_decision.dart';
import 'package:camo/core/risk_engine/domain/repositories/camo_risk_repository.dart';
import 'package:camo/core/risk_engine/domain/usecases/evaluate_camo_risk_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_risk_level.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeRiskRepository implements CamoRiskRepository {
  @override
  Future<CamoResult<CamoRiskDecision>> evaluateRisk(
    CamoRiskAssessmentContext context,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoRiskDecision>(
      CamoRiskDecision(
        decisionId: 'decision-001',
        riskLevel: CamoRiskLevel.low,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'risk_acceptable',
        score: 10,
        evaluatedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('evaluate risk use case delegates to repository', () async {
    final EvaluateCamoRiskUseCase useCase = EvaluateCamoRiskUseCase(
      _FakeRiskRepository(),
    );
    final CamoRiskAssessmentContext context = CamoRiskAssessmentContext(
      assessmentId: 'assessment-001',
      userId: 'user-001',
      deviceId: 'device-001',
      operationId: 'operation-001',
      operationType: CamoOperationType.encode,
      requestedAt: DateTime.now(),
      signals: const <Never>[],
    );
    final CamoResult<CamoRiskDecision> result = await useCase(context);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsOperation, isTrue);
  });
}
