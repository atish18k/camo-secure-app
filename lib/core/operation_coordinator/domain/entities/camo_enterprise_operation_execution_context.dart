// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_authorization_pipeline_decision.dart';
import '../../../authorization_gateway/data/models/camo_verified_signed_permit_projection_v2.dart';
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

  CamoVerifiedSignedPermitProjectionV2? get verifiedPermitV2 {
    return authorizationDecision.verifiedPermitV2;
  }

  bool get hasVerifiedV2Permit {
    return authorizationDecision.hasVerifiedV2Permit;
  }

  bool get permitsExecution {
    return request.isValid &&
        authorizationDecision.permitsOperation &&
        wrappedKeyMaterial.isUsable;
  }
}
