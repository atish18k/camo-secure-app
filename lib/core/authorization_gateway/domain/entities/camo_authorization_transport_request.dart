// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../entities/camo_authorization_gateway_request.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

final class CamoAuthorizationTransportRequest {
  const CamoAuthorizationTransportRequest({
    required this.gatewayRequest,
    required this.payload,
    required this.headers,
  });

  final CamoAuthorizationGatewayRequest gatewayRequest;
  final Map<String, Object?> payload;
  final Map<String, String> headers;

  bool get isValid {
    return gatewayRequest.isValid &&
        payload.isNotEmpty &&
        headers.keys.every((String key) => key.trim().isNotEmpty) &&
        headers.values.every((String value) => value.trim().isNotEmpty);
  }
}
