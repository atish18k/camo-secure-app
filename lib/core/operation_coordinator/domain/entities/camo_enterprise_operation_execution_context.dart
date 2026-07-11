// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_authorization_pipeline_decision.dart';
import '../../../kms/domain/entities/camo_wrapped_key_material.dart';
import 'camo_enterprise_operation_request.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoEnterpriseOperationExecutionContext {
  const CamoEnterpriseOperationExecutionContext({
    required this.request,
    required this.authorizationDecision,
    required this.wrappedKeyMaterial,
    required this.authorizedAt,
  });
  final CamoEnterpriseOperationRequest request;
  final CamoAuthorizationPipelineDecision authorizationDecision;
  final CamoWrappedKeyMaterial wrappedKeyMaterial;
  final DateTime authorizedAt;
  bool get permitsExecution {
    return request.isValid &&
        authorizationDecision.permitsOperation &&
        wrappedKeyMaterial.isUsable;
  }
}
