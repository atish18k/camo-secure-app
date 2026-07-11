// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoSecuritySessionFailure extends CamoFailure {
  const CamoSecuritySessionFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
