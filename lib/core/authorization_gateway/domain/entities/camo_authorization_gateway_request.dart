// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'camo_authorization_challenge.dart';
import 'camo_authorization_nonce.dart';
import 'camo_authorization_timestamp.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationGatewayRequest {
  CamoAuthorizationGatewayRequest({
    required this.requestId,
    required this.authorizationRequest,
    required this.challenge,
    required this.nonce,
    required this.timestamp,
    required this.deviceProof,
    Map<String, String> headers = const <String, String>{},
  }) : headers = Map<String, String>.unmodifiable(headers);
  final String requestId;
  final CamoEnterpriseAuthorizationRequest authorizationRequest;
  final CamoAuthorizationChallenge challenge;
  final CamoAuthorizationNonce nonce;
  final CamoAuthorizationTimestamp timestamp;
  final String deviceProof;
  final Map<String, String> headers;
  bool get isValid {
    return requestId.isNotEmpty &&
        authorizationRequest.isValid &&
        challenge.isUsable &&
        nonce.isValid &&
        deviceProof.isNotEmpty;
  }
}
