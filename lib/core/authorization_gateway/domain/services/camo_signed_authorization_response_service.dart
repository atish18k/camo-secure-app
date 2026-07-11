import '../entities/camo_authorization_gateway_response.dart';
import '../entities/camo_authorization_signature_verification_decision.dart';

abstract interface class CamoSignedAuthorizationResponseService {
  Future<CamoAuthorizationSignatureVerificationDecision> verifyResponse(
    CamoAuthorizationGatewayResponse response,
  );
}
