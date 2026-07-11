// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationFailure extends CamoFailure {
  const CamoAuthorizationFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
