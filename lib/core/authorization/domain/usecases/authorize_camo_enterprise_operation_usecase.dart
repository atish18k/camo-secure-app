// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_pipeline_decision.dart';
import '../entities/camo_enterprise_authorization_request.dart';
import '../services/camo_enterprise_authorization_service.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class AuthorizeCamoEnterpriseOperationUseCase {
  const AuthorizeCamoEnterpriseOperationUseCase(this._service);
  final CamoEnterpriseAuthorizationService _service;
  Future<CamoResult<CamoAuthorizationPipelineDecision>> call(
    CamoEnterpriseAuthorizationRequest request,
  ) {
    return _service.authorize(request);
  }
}
