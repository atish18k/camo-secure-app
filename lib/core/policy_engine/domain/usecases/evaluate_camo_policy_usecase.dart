// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_policy_decision.dart';
import '../entities/camo_policy_evaluation_context.dart';
import '../repositories/camo_policy_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class EvaluateCamoPolicyUseCase {
  const EvaluateCamoPolicyUseCase(this._repository);
  final CamoPolicyRepository _repository;
  Future<CamoResult<CamoPolicyDecision>> call(
    CamoPolicyEvaluationContext context,
  ) {
    return _repository.evaluatePolicy(context);
  }
}
