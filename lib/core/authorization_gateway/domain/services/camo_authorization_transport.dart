// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_transport_request.dart';
import '../entities/camo_authorization_transport_response.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------

abstract interface class CamoAuthorizationTransport {
  Future<CamoResult<CamoAuthorizationTransportResponse>> send(
    CamoAuthorizationTransportRequest request,
  );
}
