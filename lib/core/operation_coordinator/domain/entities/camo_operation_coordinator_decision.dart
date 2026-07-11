// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_authorized_operation_handle.dart';
import 'camo_operation_stage.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoOperationCoordinatorDecision {
  const CamoOperationCoordinatorDecision({
    required this.operationId,
    required this.stage,
    required this.securityDecision,
    required this.reasonCode,
    required this.decidedAt,
    this.handle,
  });
  final String operationId;
  final CamoOperationStage stage;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final DateTime decidedAt;
  final CamoAuthorizedOperationHandle? handle;
  bool get permitsExecution {
    return stage.permitsExecution &&
        securityDecision.isAllowed &&
        handle?.isUsable == true;
  }
}
