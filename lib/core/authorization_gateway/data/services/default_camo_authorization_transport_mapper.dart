// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../../../authorization/domain/entities/camo_authorization_pipeline_decision.dart';
import '../../domain/entities/camo_authorization_gateway_request.dart';
import '../../domain/entities/camo_authorization_gateway_response.dart';
import '../../domain/entities/camo_authorization_transport_request.dart';
import '../../domain/entities/camo_authorization_transport_response.dart';
import '../../domain/services/camo_authorization_transport_mapper.dart';

// -----------------------------------------------------------------------------
// Mapper
// -----------------------------------------------------------------------------

final class DefaultCamoAuthorizationTransportMapper
    implements CamoAuthorizationTransportMapper {
  const DefaultCamoAuthorizationTransportMapper();

  @override
  CamoAuthorizationTransportRequest mapRequest(
    CamoAuthorizationGatewayRequest request,
  ) {
    if (!request.isValid) {
      throw StateError('Authorization Gateway request is invalid.');
    }

    return CamoAuthorizationTransportRequest(
      gatewayRequest: request,
      headers: Map<String, String>.unmodifiable(<String, String>{
        ...request.headers,
        'content-type': 'application/json',
        'x-camo-request-id': request.requestId.trim(),
        'x-camo-operation-id': request.authorizationRequest.operationId.trim(),
        'x-camo-device-id': request.authorizationRequest.deviceId.trim(),
      }),
      payload: Map<String, Object?>.unmodifiable(<String, Object?>{
        'requestId': request.requestId.trim(),
        'operationId': request.authorizationRequest.operationId.trim(),
        'userId': request.authorizationRequest.userId.trim(),
        'deviceId': request.authorizationRequest.deviceId.trim(),
        'operationType': request.authorizationRequest.operationType.name,
        'keyPurpose': request.authorizationRequest.keyPurpose.name,
        'keyScope': request.authorizationRequest.keyScope.name,
        'requestedAt': request.authorizationRequest.requestedAt
            .toUtc()
            .toIso8601String(),
        'pairId': request.authorizationRequest.pairId?.trim(),
        'messageId': request.authorizationRequest.messageId?.trim(),
        'challengeId': request.challenge.challengeId.trim(),
        'challenge': request.challenge.challenge.trim(),
        'challengeIssuedAt': request.challenge.issuedAt
            .toUtc()
            .toIso8601String(),
        'challengeExpiresAt': request.challenge.expiresAt
            .toUtc()
            .toIso8601String(),
        'nonce': request.nonce.value.trim(),
        'clientTime': request.timestamp.clientTime.toUtc().toIso8601String(),
        'deviceProof': request.deviceProof.trim(),
        'requiredEntitlements': request
            .authorizationRequest
            .requiredEntitlements
            .map((entitlement) => entitlement.name)
            .toList(growable: false),
        'attributes': request.authorizationRequest.attributes,
      }),
    );
  }

  @override
  CamoAuthorizationGatewayResponse mapResponse(
    CamoAuthorizationTransportResponse response,
  ) {
    if (!response.isValid || !response.isSuccessful) {
      throw StateError('Authorization transport response is invalid.');
    }

    final Map<String, Object?> payload = response.payload;

    final Object? responseIdValue = payload['responseId'];
    final Object? requestIdValue = payload['requestId'];
    final Object? pipelineDecisionValue = payload['pipelineDecision'];
    final Object? serverTimeValue = payload['serverTime'];
    final Object? signatureValue = payload['signature'];

    if (responseIdValue is! String ||
        requestIdValue is! String ||
        pipelineDecisionValue is! CamoAuthorizationPipelineDecision ||
        serverTimeValue is! String ||
        signatureValue is! String) {
      throw StateError(
        'Authorization transport response payload is incomplete.',
      );
    }

    final DateTime? serverTime = DateTime.tryParse(serverTimeValue);

    if (responseIdValue.trim().isEmpty ||
        requestIdValue.trim().isEmpty ||
        signatureValue.trim().isEmpty ||
        serverTime == null) {
      throw StateError(
        'Authorization transport response payload is malformed.',
      );
    }

    return CamoAuthorizationGatewayResponse(
      responseId: responseIdValue.trim(),
      requestId: requestIdValue.trim(),
      pipelineDecision: pipelineDecisionValue,
      serverTime: serverTime.toUtc(),
      signature: signatureValue.trim(),
    );
  }
}
