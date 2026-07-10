// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/camo_policy_context.dart';
import '../../domain/entities/camo_policy_failure_reason.dart';
import '../../domain/entities/camo_policy_operation.dart';
import '../../domain/entities/camo_policy_result.dart';
import '../../domain/repositories/camo_policy_evaluator.dart';

// ---------------------------------------------------------------------------
// CAMO Policy Evaluator Implementation
// ---------------------------------------------------------------------------

class CamoPolicyEvaluatorImpl implements CamoPolicyEvaluator {
  const CamoPolicyEvaluatorImpl();

  // ---------------------------------------------------------------------------
  // Evaluate
  // ---------------------------------------------------------------------------

  @override
  CamoPolicyResult evaluate(
    CamoPolicyContext context,
  ) {
    final CamoPolicyResult commonResult =
        _evaluateCommonPolicies(context);

    if (commonResult.isDenied) {
      return commonResult;
    }

    switch (context.operation) {
      case CamoPolicyOperation.encode:
        return _evaluateEncodePolicies(context);

      case CamoPolicyOperation.decode:
        return _evaluateDecodePolicies(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Common Policies
  // ---------------------------------------------------------------------------

  CamoPolicyResult _evaluateCommonPolicies(
    CamoPolicyContext context,
  ) {
    if (!context.isAuthenticated ||
        context.currentUserId.trim().isEmpty) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.authenticationRequired,
      );
    }

    if (!context.isDeviceValid ||
        context.deviceId.trim().isEmpty) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.deviceMismatch,
      );
    }

    if (!context.isLicenseValid) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.licenseExpired,
      );
    }

    if (!context.isPairAccepted ||
        context.pairingId.trim().isEmpty) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.pairNotAccepted,
      );
    }

    if (context.isBlocked) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.blocked,
      );
    }

    if (context.policyVersion !=
        context.requiredPolicyVersion) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.policyVersionMismatch,
      );
    }

    return const CamoPolicyResult.allow();
  }

  // ---------------------------------------------------------------------------
  // Encode Policies
  // ---------------------------------------------------------------------------

  CamoPolicyResult _evaluateEncodePolicies(
    CamoPolicyContext context,
  ) {
    return const CamoPolicyResult.allow();
  }

  // ---------------------------------------------------------------------------
  // Decode Policies
  // ---------------------------------------------------------------------------

  CamoPolicyResult _evaluateDecodePolicies(
    CamoPolicyContext context,
  ) {
    if (context.messageId == null ||
        context.messageId!.trim().isEmpty) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.policyViolation,
      );
    }

    if (context.isDeleted) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.deleted,
      );
    }

    if (context.isRevoked) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.revoked,
      );
    }

    if (context.isBurned) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.burned,
      );
    }

    if (context.isExpired) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.messageExpired,
      );
    }

    return const CamoPolicyResult.allow();
  }
}