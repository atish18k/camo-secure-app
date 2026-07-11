// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_authorization_pipeline_decision.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationGatewayResponse {
  const CamoAuthorizationGatewayResponse({
    required this.responseId,
    required this.requestId,
    required this.pipelineDecision,
    required this.serverTime,
    required this.signature,
  });
  final String responseId;
  final String requestId;
  final CamoAuthorizationPipelineDecision pipelineDecision;
  final DateTime serverTime;
  final String signature;
  bool get hasValidSignature => signature.isNotEmpty;
  bool get permitsOperation {
    return responseId.isNotEmpty &&
        requestId.isNotEmpty &&
        hasValidSignature &&
        pipelineDecision.permitsOperation;
  }
}
