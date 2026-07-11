import '../../domain/entities/camo_authorization_gateway_response.dart';
import '../../domain/entities/camo_authorization_response_signature_payload.dart';
import '../../domain/services/camo_authorization_response_canonicalizer.dart';

final class DefaultCamoAuthorizationResponseCanonicalizer
    implements CamoAuthorizationResponseCanonicalizer {
  const DefaultCamoAuthorizationResponseCanonicalizer();

  @override
  CamoAuthorizationResponseSignaturePayload createPayload(
    CamoAuthorizationGatewayResponse response,
  ) {
    return CamoAuthorizationResponseSignaturePayload(
      responseId: response.responseId,
      requestId: response.requestId,
      operationId: response.pipelineDecision.session.token.operationId,
      sessionId: response.pipelineDecision.session.sessionId,
      keyReleaseId: response.pipelineDecision.keyReleaseDecision.releaseId,
      serverTime: response.serverTime,
    );
  }
}
