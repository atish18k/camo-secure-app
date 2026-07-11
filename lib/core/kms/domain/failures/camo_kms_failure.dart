// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoKmsFailure extends CamoFailure {
  const CamoKmsFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
