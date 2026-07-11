// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_policy_decision.dart';
import '../entities/camo_policy_evaluation_context.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoPolicyRepository {
  Future<CamoResult<CamoPolicyDecision>> evaluatePolicy(
    CamoPolicyEvaluationContext context,
  );
}
