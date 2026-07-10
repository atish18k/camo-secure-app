// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_policy_context.dart';
import '../entities/camo_policy_result.dart';
import '../repositories/camo_policy_evaluator.dart';

// ---------------------------------------------------------------------------
// Evaluate CAMO Policy Use Case
// ---------------------------------------------------------------------------

class EvaluateCamoPolicyUseCase {
  const EvaluateCamoPolicyUseCase(
    this._policyEvaluator,
  );

  final CamoPolicyEvaluator _policyEvaluator;

  CamoPolicyResult call(
    CamoPolicyContext context,
  ) {
    return _policyEvaluator.evaluate(context);
  }
}