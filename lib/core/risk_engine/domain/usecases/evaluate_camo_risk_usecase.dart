// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_risk_assessment_context.dart';
import '../entities/camo_risk_decision.dart';
import '../repositories/camo_risk_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class EvaluateCamoRiskUseCase {
  const EvaluateCamoRiskUseCase(this._repository);
  final CamoRiskRepository _repository;
  Future<CamoResult<CamoRiskDecision>> call(CamoRiskAssessmentContext context) {
    return _repository.evaluateRisk(context);
  }
}
