import '../entities/camo_authorization_gateway_response.dart';
import '../entities/camo_authorization_response_signature_payload.dart';

abstract interface class CamoAuthorizationResponseCanonicalizer {
  CamoAuthorizationResponseSignaturePayload createPayload(
    CamoAuthorizationGatewayResponse response,
  );
}
