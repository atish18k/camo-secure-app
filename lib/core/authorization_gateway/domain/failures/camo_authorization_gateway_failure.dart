// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationGatewayFailure extends CamoFailure {
  const CamoAuthorizationGatewayFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
