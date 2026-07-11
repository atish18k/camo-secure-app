// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoRiskFailure extends CamoFailure {
  const CamoRiskFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
