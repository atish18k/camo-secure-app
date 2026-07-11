// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_challenge.dart';
import '../entities/camo_authorization_gateway_request.dart';
import '../entities/camo_authorization_gateway_response.dart';
import '../entities/camo_replay_protection_decision.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoAuthorizationGatewayRepository {
  Future<CamoResult<CamoAuthorizationChallenge>> requestChallenge({
    required String userId,
    required String deviceId,
  });
  Future<CamoResult<CamoAuthorizationGatewayResponse>> submitAuthorization(
    CamoAuthorizationGatewayRequest request,
  );
  Future<CamoResult<CamoReplayProtectionDecision>> validateReplayProtection({
    required String challengeId,
    required String nonce,
    required DateTime clientTime,
  });
  Future<CamoResult<void>> consumeChallenge(String challengeId);
}
