// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoOperationCoordinatorFailure extends CamoFailure {
  const CamoOperationCoordinatorFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
