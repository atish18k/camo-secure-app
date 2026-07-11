// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_authorization_pipeline_decision.dart';
import '../../../kms/domain/entities/camo_key_release_decision.dart';
import '../../../shared/types/camo_operation_type.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizedOperationHandle {
  const CamoAuthorizedOperationHandle({
    required this.operationId,
    required this.operationType,
    required this.pipelineDecision,
    required this.issuedAt,
  });
  final String operationId;
  final CamoOperationType operationType;
  final CamoAuthorizationPipelineDecision pipelineDecision;
  final DateTime issuedAt;
  String get sessionId => pipelineDecision.session.sessionId;
  CamoKeyReleaseDecision get keyReleaseDecision {
    return pipelineDecision.keyReleaseDecision;
  }

  bool get isUsable {
    return operationId.isNotEmpty &&
        (operationType == CamoOperationType.encode ||
            operationType == CamoOperationType.decode) &&
        pipelineDecision.permitsOperation;
  }
}
