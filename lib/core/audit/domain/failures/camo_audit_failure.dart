// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuditFailure extends CamoFailure {
  const CamoAuditFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
