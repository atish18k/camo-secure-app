// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_challenge.dart';
import '../repositories/camo_authorization_gateway_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RequestCamoAuthorizationChallengeUseCase {
  const RequestCamoAuthorizationChallengeUseCase(this._repository);
  final CamoAuthorizationGatewayRepository _repository;
  Future<CamoResult<CamoAuthorizationChallenge>> call({
    required String userId,
    required String deviceId,
  }) {
    return _repository.requestChallenge(userId: userId, deviceId: deviceId);
  }
}
