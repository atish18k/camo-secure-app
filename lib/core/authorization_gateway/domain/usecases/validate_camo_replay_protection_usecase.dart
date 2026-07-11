// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_replay_protection_decision.dart';
import '../repositories/camo_authorization_gateway_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ValidateCamoReplayProtectionUseCase {
  const ValidateCamoReplayProtectionUseCase(this._repository);
  final CamoAuthorizationGatewayRepository _repository;
  Future<CamoResult<CamoReplayProtectionDecision>> call({
    required String challengeId,
    required String nonce,
    required DateTime clientTime,
  }) {
    return _repository.validateReplayProtection(
      challengeId: challengeId,
      nonce: nonce,
      clientTime: clientTime,
    );
  }
}
