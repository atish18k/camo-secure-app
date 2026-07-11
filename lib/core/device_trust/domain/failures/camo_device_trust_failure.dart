// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoDeviceTrustFailure extends CamoFailure {
  const CamoDeviceTrustFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
