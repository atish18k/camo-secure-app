// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoPolicyFailure extends CamoFailure {
  const CamoPolicyFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
