// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_policy_context.dart';
import '../entities/camo_policy_result.dart';

// ---------------------------------------------------------------------------
// CAMO Policy Evaluator
// ---------------------------------------------------------------------------

/// Evaluates whether a protected CAMO operation is allowed.
///
/// Implementations must remain deterministic and side-effect free.
/// Plaintext, private keys, and decrypted data must never be supplied here.
abstract class CamoPolicyEvaluator {
  CamoPolicyResult evaluate(
    CamoPolicyContext context,
  );
}