// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/camo_authorization_gateway_response.dart';
import '../../domain/entities/camo_authorization_signature_verification_decision.dart';
import '../../domain/services/camo_authorization_response_canonicalizer.dart';
import '../../domain/services/camo_authorization_response_signature_verifier.dart';
import '../../domain/services/camo_signed_authorization_response_service.dart';

final class DefaultCamoSignedAuthorizationResponseService
    implements CamoSignedAuthorizationResponseService {
  const DefaultCamoSignedAuthorizationResponseService({
    required CamoAuthorizationResponseCanonicalizer canonicalizer,
    required CamoAuthorizationResponseSignatureVerifier verifier,
  }) : _canonicalizer = canonicalizer,
       _verifier = verifier;

  final CamoAuthorizationResponseCanonicalizer _canonicalizer;
  final CamoAuthorizationResponseSignatureVerifier _verifier;

  @override
  Future<CamoAuthorizationSignatureVerificationDecision> verifyResponse(
    CamoAuthorizationGatewayResponse response,
  ) async {
    if (response.responseId.trim().isEmpty ||
        response.requestId.trim().isEmpty) {
      return const CamoAuthorizationSignatureVerificationDecision.denied(
        'authorization_response_identity_invalid',
      );
    }

    final String signature = response.signature.trim();

    if (signature.isEmpty) {
      return const CamoAuthorizationSignatureVerificationDecision.denied(
        'authorization_response_signature_missing',
      );
    }

    if (!response.pipelineDecision.permitsOperation) {
      return const CamoAuthorizationSignatureVerificationDecision.denied(
        'authorization_pipeline_decision_denied',
      );
    }

    try {
      final payload = _canonicalizer.createPayload(response);

      if (!payload.isValid) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_response_signature_payload_invalid',
        );
      }

      return _verifier.verify(payload: payload, signature: signature);
    } catch (_) {
      return const CamoAuthorizationSignatureVerificationDecision.denied(
        'authorization_response_signature_verification_failed',
      );
    }
  }
}
