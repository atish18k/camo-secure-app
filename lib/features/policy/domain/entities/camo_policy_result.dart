// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'camo_policy_decision.dart';
import 'camo_policy_failure_reason.dart';

// ---------------------------------------------------------------------------
// CAMO Policy Result
// ---------------------------------------------------------------------------

/// Immutable result returned by the CAMO Policy Engine.
///
/// The Crypto Engine must continue only when [isAllowed] is true.
class CamoPolicyResult {
  // ---------------------------------------------------------------------------
  // Constructors
  // ---------------------------------------------------------------------------

  const CamoPolicyResult._({
    required this.decision,
    this.failureReason,
  });

  const CamoPolicyResult.allow()
      : this._(
          decision: CamoPolicyDecision.allow,
        );

  const CamoPolicyResult.deny(
    CamoPolicyFailureReason reason,
  ) : this._(
          decision: CamoPolicyDecision.deny,
          failureReason: reason,
        );

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final CamoPolicyDecision decision;
  final CamoPolicyFailureReason? failureReason;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool get isAllowed => decision == CamoPolicyDecision.allow;

  bool get isDenied => decision == CamoPolicyDecision.deny;
}