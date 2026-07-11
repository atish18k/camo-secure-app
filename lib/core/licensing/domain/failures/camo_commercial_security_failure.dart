// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoCommercialSecurityFailure extends CamoFailure {
  const CamoCommercialSecurityFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
