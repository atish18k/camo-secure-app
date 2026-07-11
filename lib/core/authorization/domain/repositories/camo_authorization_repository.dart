// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_context.dart';
import '../entities/camo_authorization_decision.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoAuthorizationRepository {
  Future<CamoResult<CamoAuthorizationDecision>> authorizeOperation(
    CamoAuthorizationContext context,
  );
  Future<CamoResult<void>> consumeAuthorization(String authorizationId);
}
