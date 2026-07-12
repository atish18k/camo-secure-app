// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_authorization_gateway_request.dart';
import '../../domain/entities/camo_authorization_gateway_response.dart';
import '../../domain/services/camo_authorization_response_acceptance_service.dart';
import '../../domain/services/camo_authorization_transport.dart';
import '../../domain/services/camo_authorization_transport_mapper.dart';
import '../../domain/services/camo_production_authorization_gateway_adapter.dart';
import '../../domain/services/camo_signed_authorization_response_service.dart';
import '../../domain/services/camo_single_use_authorization_artifact_factory.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

final class TransportBackedCamoProductionAuthorizationGatewayAdapter
    implements CamoProductionAuthorizationGatewayAdapter {
  const TransportBackedCamoProductionAuthorizationGatewayAdapter({
    required this._transport,
    required this._mapper,
    this._signedResponseService,
    this._artifactFactory,
    this._acceptanceService,
  });

  final CamoAuthorizationTransport _transport;
  final CamoAuthorizationTransportMapper _mapper;
  final CamoSignedAuthorizationResponseService? _signedResponseService;
  final CamoSingleUseAuthorizationArtifactFactory? _artifactFactory;
  final CamoAuthorizationResponseAcceptanceService? _acceptanceService;

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  ) async {
    if (!request.isValid) {
      return const CamoError<CamoAuthorizationGatewayResponse>(
        CamoValidationFailure(
          code: 'authorization_gateway_request_invalid',
          message: 'Authorization Gateway request is invalid.',
        ),
      );
    }

    try {
      final transportRequest = _mapper.mapRequest(request);

      if (!transportRequest.isValid) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoValidationFailure(
            code: 'authorization_transport_request_invalid',
            message: 'Authorization transport request is invalid.',
          ),
        );
      }

      final transportResult = await _transport.send(transportRequest);

      if (transportResult.isFailure) {
        return CamoError<CamoAuthorizationGatewayResponse>(
          transportResult.failureOrNull ??
              const CamoNetworkFailure(
                code: 'authorization_transport_failed',
                message: 'Authorization transport failed closed.',
              ),
        );
      }

      final transportResponse = transportResult.valueOrNull;

      if (transportResponse == null || !transportResponse.isValid) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_transport_response_invalid',
            message: 'Authorization transport response is invalid.',
          ),
        );
      }

      final gatewayResponse = _mapper.mapResponse(transportResponse);

      if (gatewayResponse.requestId != request.requestId) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_response_request_mismatch',
            message: 'Authorization response request binding failed.',
          ),
        );
      }

      final signedResponseService = _signedResponseService;

      if (signedResponseService == null) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_signature_service_unavailable',
            message:
                'Authorization response signature verification is unavailable.',
          ),
        );
      }

      final signatureDecision = await signedResponseService.verifyResponse(
        gatewayResponse,
      );

      if (!signatureDecision.permitsResponseUse) {
        return CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: signatureDecision.reasonCode.trim().isEmpty
                ? 'authorization_response_signature_denied'
                : signatureDecision.reasonCode.trim(),
            message:
                'Authorization response signature verification was denied.',
          ),
        );
      }

      final artifactFactory = _artifactFactory;
      final acceptanceService = _acceptanceService;

      if (artifactFactory == null || acceptanceService == null) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_response_acceptance_service_unavailable',
            message:
                'Authorization response acceptance services are unavailable.',
          ),
        );
      }

      final singleUseArtifact = artifactFactory.create(
        operationId: request.authorizationRequest.operationId,
        authorizationId: gatewayResponse.responseId,
        challengeId: request.challenge.challengeId,
        issuedAt: gatewayResponse.serverTime,
        expiresAt: request.challenge.expiresAt,
      );

      if (!singleUseArtifact.isStructurallyValid) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'single_use_authorization_artifact_invalid',
            message: 'Single-use authorization artifact is invalid.',
          ),
        );
      }

      final acceptanceDecision = await acceptanceService.accept(
        signatureDecision: signatureDecision,
        singleUseArtifact: singleUseArtifact,
      );

      if (!acceptanceDecision.permitsCoordinatorUse) {
        return CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: acceptanceDecision.reasonCode.trim().isEmpty
                ? 'authorization_response_acceptance_denied'
                : acceptanceDecision.reasonCode.trim(),
            message:
                'Authorization response acceptance and replay protection failed.',
          ),
        );
      }

      return CamoSuccess<CamoAuthorizationGatewayResponse>(gatewayResponse);
    } on Object catch (error) {
      return CamoError<CamoAuthorizationGatewayResponse>(
        CamoUnexpectedFailure(
          code: 'production_authorization_adapter_unexpected_failure',
          message: 'Production Authorization Gateway adapter failed closed.',
          cause: error,
        ),
      );
    }
  }
}
