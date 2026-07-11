// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_gateway_request.dart';
import '../entities/camo_authorization_gateway_response.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------
abstract interface class CamoAuthorizationGateway {
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  );
}
