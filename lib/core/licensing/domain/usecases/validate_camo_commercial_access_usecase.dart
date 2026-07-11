// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_commercial_access_context.dart';
import '../entities/camo_commercial_access_decision.dart';
import '../repositories/camo_commercial_security_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ValidateCamoCommercialAccessUseCase {
  const ValidateCamoCommercialAccessUseCase(this._repository);
  final CamoCommercialSecurityRepository _repository;
  Future<CamoResult<CamoCommercialAccessDecision>> call(
    CamoCommercialAccessContext context,
  ) {
    return _repository.validateCommercialAccess(context);
  }
}
