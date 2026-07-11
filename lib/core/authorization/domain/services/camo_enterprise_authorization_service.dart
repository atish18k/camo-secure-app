// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_pipeline_decision.dart';
import '../entities/camo_enterprise_authorization_request.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------
abstract interface class CamoEnterpriseAuthorizationService {
  Future<CamoResult<CamoAuthorizationPipelineDecision>> authorize(
    CamoEnterpriseAuthorizationRequest request,
  );
  Future<CamoResult<void>> consumeSession(String sessionId);
}
