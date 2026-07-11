// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import 'camo_authorization_gateway.dart';

// -----------------------------------------------------------------------------
// Production Authorization Gateway Adapter
// -----------------------------------------------------------------------------

/// Marker contract for a production-capable Authorization Gateway adapter.
///
/// Registering an implementation of this contract does not activate production
/// authorization. Runtime selection must still pass the production activation
/// guard and the safe Gateway resolver.
abstract interface class CamoProductionAuthorizationGatewayAdapter
    implements CamoAuthorizationGateway {}