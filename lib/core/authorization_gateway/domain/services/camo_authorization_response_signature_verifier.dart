import '../entities/camo_authorization_response_signature_payload.dart';
import '../entities/camo_authorization_signature_verification_decision.dart';

abstract interface class CamoAuthorizationResponseSignatureVerifier {
  Future<CamoAuthorizationSignatureVerificationDecision> verify({
    required CamoAuthorizationResponseSignaturePayload payload,
    required String signature,
  });
}
