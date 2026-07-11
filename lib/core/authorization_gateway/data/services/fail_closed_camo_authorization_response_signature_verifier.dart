import '../../domain/entities/camo_authorization_response_signature_payload.dart';
import '../../domain/entities/camo_authorization_signature_verification_decision.dart';
import '../../domain/services/camo_authorization_response_signature_verifier.dart';

final class FailClosedCamoAuthorizationResponseSignatureVerifier
    implements CamoAuthorizationResponseSignatureVerifier {
  const FailClosedCamoAuthorizationResponseSignatureVerifier();

  @override
  Future<CamoAuthorizationSignatureVerificationDecision> verify({
    required CamoAuthorizationResponseSignaturePayload payload,
    required String signature,
  }) async {
    return const CamoAuthorizationSignatureVerificationDecision.denied(
      'production_server_signature_verifier_unavailable',
    );
  }
}
