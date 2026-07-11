// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_enterprise_operation_stage.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoEnterpriseOperationOutcome {
  const CamoEnterpriseOperationOutcome({
    required this.operationId,
    required this.stage,
    required this.securityDecision,
    required this.reasonCode,
    required this.completedAt,
    this.resultReference,
  });
  final String operationId;
  final CamoEnterpriseOperationStage stage;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final DateTime completedAt;
  final String? resultReference;
  bool get isSuccessful {
    return stage.isSuccessful &&
        securityDecision.isAllowed &&
        operationId.isNotEmpty;
  }
}
