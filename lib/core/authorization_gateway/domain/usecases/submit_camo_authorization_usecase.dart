// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_gateway_request.dart';
import '../entities/camo_authorization_gateway_response.dart';
import '../repositories/camo_authorization_gateway_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class SubmitCamoAuthorizationUseCase {
  const SubmitCamoAuthorizationUseCase(this._repository);
  final CamoAuthorizationGatewayRepository _repository;
  Future<CamoResult<CamoAuthorizationGatewayResponse>> call(
    CamoAuthorizationGatewayRequest request,
  ) {
    return _repository.submitAuthorization(request);
  }
}
