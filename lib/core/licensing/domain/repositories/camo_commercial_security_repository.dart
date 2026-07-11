// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_commercial_access_context.dart';
import '../entities/camo_commercial_access_decision.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoCommercialSecurityRepository {
  Future<CamoResult<CamoCommercialAccessDecision>> validateCommercialAccess(
    CamoCommercialAccessContext context,
  );
}
