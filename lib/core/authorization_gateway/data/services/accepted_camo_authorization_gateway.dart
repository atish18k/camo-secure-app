// ignore_for_file: prefer_initializing_formals

import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_response.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_gateway.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_response_acceptance_service.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_signed_authorization_response_service.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_single_use_authorization_artifact_factory.dart';
import 'package:camo/core/shared/failures/camo_failure.dart';
import 'package:camo/core/shared/result/camo_result.dart';

final class AcceptedCamoAuthorizationGateway
    implements CamoAuthorizationGateway {
  const AcceptedCamoAuthorizationGateway({
    required CamoAuthorizationGateway delegate,
    required CamoSignedAuthorizationResponseService signedResponseService,
    required CamoAuthorizationResponseAcceptanceService acceptanceService,
    required CamoSingleUseAuthorizationArtifactFactory artifactFactory,
  }) : _delegate = delegate,
       _signedResponseService = signedResponseService,
       _acceptanceService = acceptanceService,
       _artifactFactory = artifactFactory;

  final CamoAuthorizationGateway _delegate;
  final CamoSignedAuthorizationResponseService _signedResponseService;
  final CamoAuthorizationResponseAcceptanceService _acceptanceService;
  final CamoSingleUseAuthorizationArtifactFactory _artifactFactory;

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  ) async {
    if (!request.isValid) {
      return const CamoError<CamoAuthorizationGatewayResponse>(
        CamoValidationFailure(
          code: 'invalid_authorization_gateway_request',
          message: 'Authorization Gateway request is invalid.',
        ),
      );
    }

    try {
      final CamoResult<CamoAuthorizationGatewayResponse> gatewayResult =
          await _delegate.authorize(request);

      if (gatewayResult.isFailure) {
        return CamoError<CamoAuthorizationGatewayResponse>(
          gatewayResult.failureOrNull ??
              const CamoSecurityFailure(
                code: 'authorization_gateway_failed',
                message: 'Authorization Gateway request failed.',
              ),
        );
      }

      final CamoAuthorizationGatewayResponse? response =
          gatewayResult.valueOrNull;

      if (response == null) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_gateway_response_missing',
            message: 'Authorization Gateway response is missing.',
          ),
        );
      }

      if (response.requestId.trim() != request.requestId.trim()) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_gateway_request_binding_mismatch',
            message: 'Authorization response request binding is invalid.',
          ),
        );
      }

      final token = response.pipelineDecision.session.token;

      if (token.operationId.trim() !=
          request.authorizationRequest.operationId.trim()) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_gateway_operation_binding_mismatch',
            message: 'Authorization response operation binding is invalid.',
          ),
        );
      }

      if (token.userId.trim() != request.authorizationRequest.userId.trim() ||
          token.deviceId.trim() !=
              request.authorizationRequest.deviceId.trim()) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_gateway_identity_binding_mismatch',
            message: 'Authorization response identity binding is invalid.',
          ),
        );
      }

      final signatureDecision = await _signedResponseService.verifyResponse(
        response,
      );

      final artifact = _artifactFactory.create(
        operationId: token.operationId,
        authorizationId: token.authorizationId,
        challengeId: request.challenge.challengeId,
        issuedAt: token.issuedAt,
        expiresAt: token.expiresAt,
      );

      final acceptanceDecision = await _acceptanceService.accept(
        signatureDecision: signatureDecision,
        singleUseArtifact: artifact,
      );

      if (!acceptanceDecision.permitsCoordinatorUse) {
        return CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: acceptanceDecision.reasonCode.trim().isEmpty
                ? 'authorization_response_acceptance_failed'
                : acceptanceDecision.reasonCode,
            message:
                'Authorization response was rejected by the acceptance pipeline.',
          ),
        );
      }

      return CamoSuccess<CamoAuthorizationGatewayResponse>(response);
    } catch (_) {
      return const CamoError<CamoAuthorizationGatewayResponse>(
        CamoSecurityFailure(
          code: 'authorization_gateway_acceptance_pipeline_failed',
          message: 'Authorization Gateway acceptance pipeline failed closed.',
        ),
      );
    }
  }
}
