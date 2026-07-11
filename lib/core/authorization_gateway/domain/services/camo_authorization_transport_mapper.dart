// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../entities/camo_authorization_gateway_request.dart';
import '../entities/camo_authorization_gateway_response.dart';
import '../entities/camo_authorization_transport_request.dart';
import '../entities/camo_authorization_transport_response.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------

abstract interface class CamoAuthorizationTransportMapper {
  CamoAuthorizationTransportRequest mapRequest(
    CamoAuthorizationGatewayRequest request,
  );

  CamoAuthorizationGatewayResponse mapResponse(
    CamoAuthorizationTransportResponse response,
  );
}
