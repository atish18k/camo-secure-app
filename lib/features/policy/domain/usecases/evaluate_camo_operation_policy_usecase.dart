// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../pairing/domain/entities/pairing_entity.dart';
import '../../../pairing/domain/repositories/pairing_repository.dart';
import '../entities/camo_policy_context.dart';
import '../entities/camo_policy_failure_reason.dart';
import '../entities/camo_policy_operation.dart';
import '../entities/camo_policy_result.dart';
import '../repositories/camo_policy_evaluator.dart';
import '../repositories/camo_policy_runtime_state_provider.dart';

// ---------------------------------------------------------------------------
// Evaluate CAMO Operation Policy Use Case
// ---------------------------------------------------------------------------

/// Builds a trusted policy context and evaluates a protected CAMO operation.
///
/// This use case must complete successfully before encryption or decryption
/// is allowed to start.
class EvaluateCamoOperationPolicyUseCase {
  const EvaluateCamoOperationPolicyUseCase(
    this._authRepository,
    this._pairingRepository,
    this._runtimeStateProvider,
    this._policyEvaluator,
  );

  final AuthRepository _authRepository;
  final PairingRepository _pairingRepository;
  final CamoPolicyRuntimeStateProvider _runtimeStateProvider;
  final CamoPolicyEvaluator _policyEvaluator;

  Future<CamoPolicyResult> call({
    required CamoPolicyOperation operation,
    required String pairingId,
    String? messageId,
  }) async {
    final String? currentUserId = _authRepository.currentUserId;

    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.authenticationRequired,
      );
    }

    final PairingEntity? pairing =
        await _pairingRepository.getPairingById(pairingId);

    if (pairing == null ||
        !_isCurrentUserPartOfPairing(
          pairing: pairing,
          currentUserId: currentUserId,
        )) {
      return const CamoPolicyResult.deny(
        CamoPolicyFailureReason.pairNotAccepted,
      );
    }

    final runtimeState = await _runtimeStateProvider.getRuntimeState(
      operation: operation,
      pairingId: pairingId,
      messageId: messageId,
    );

    final CamoPolicyContext context = CamoPolicyContext(
      operation: operation,
      currentUserId: currentUserId,
      deviceId: runtimeState.deviceId,
      pairingId: pairingId,
      messageId: runtimeState.messageId,
      isAuthenticated: true,
      isDeviceValid: runtimeState.isDeviceValid,
      isLicenseValid: runtimeState.isLicenseValid,
      isPairAccepted: pairing.status == PairingStatus.accepted,
      isExpired: runtimeState.isExpired,
      isBurned: runtimeState.isBurned,
      isDeleted: runtimeState.isDeleted,
      isRevoked: runtimeState.isRevoked,
      isBlocked: runtimeState.isBlocked,
      policyVersion: runtimeState.policyVersion,
      requiredPolicyVersion: runtimeState.requiredPolicyVersion,
    );

    return _policyEvaluator.evaluate(context);
  }

  bool _isCurrentUserPartOfPairing({
    required PairingEntity pairing,
    required String currentUserId,
  }) {
    return pairing.requesterUid == currentUserId ||
        pairing.receiverUid == currentUserId;
  }
}