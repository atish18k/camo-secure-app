// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_risk_assessment_context.dart';
import '../entities/camo_risk_decision.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoRiskRepository {
  Future<CamoResult<CamoRiskDecision>> evaluateRisk(
    CamoRiskAssessmentContext context,
  );
}
