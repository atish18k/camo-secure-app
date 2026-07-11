// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../repositories/camo_authorization_gateway_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ConsumeCamoAuthorizationChallengeUseCase {
  const ConsumeCamoAuthorizationChallengeUseCase(this._repository);
  final CamoAuthorizationGatewayRepository _repository;
  Future<CamoResult<void>> call(String challengeId) {
    return _repository.consumeChallenge(challengeId);
  }
}
