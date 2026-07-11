// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../../domain/entities/camo_authorization_gateway_request.dart';
import '../../domain/entities/camo_authorization_gateway_response.dart';
import '../../domain/services/camo_production_authorization_gateway_adapter.dart';
import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';

// -----------------------------------------------------------------------------
// Fail-Closed Production Authorization Gateway Adapter
// -----------------------------------------------------------------------------

/// Safe placeholder used until the real server transport, response signing,
/// replay persistence, App Check and production readiness controls are complete.
///
/// This adapter must never authorize encode or decode operations.
final class FailClosedCamoProductionAuthorizationGatewayAdapter
    implements CamoProductionAuthorizationGatewayAdapter {
  const FailClosedCamoProductionAuthorizationGatewayAdapter();

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  ) async {
    return const CamoError<CamoAuthorizationGatewayResponse>(
      CamoSecurityFailure(
        code: 'production_authorization_gateway_adapter_unavailable',
        message:
            'Production Authorization Gateway adapter is not available.',
      ),
    );
  }
}