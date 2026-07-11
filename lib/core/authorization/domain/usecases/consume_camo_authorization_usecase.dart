// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../repositories/camo_authorization_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ConsumeCamoAuthorizationUseCase {
  const ConsumeCamoAuthorizationUseCase(this._repository);
  final CamoAuthorizationRepository _repository;
  Future<CamoResult<void>> call(String authorizationId) {
    return _repository.consumeAuthorization(authorizationId);
  }
}
