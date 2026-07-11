// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_security_session_validation_context.dart';
import '../entities/camo_security_session_validation_decision.dart';
import '../repositories/camo_security_session_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ValidateCamoSecuritySessionUseCase {
  const ValidateCamoSecuritySessionUseCase(this._repository);
  final CamoSecuritySessionRepository _repository;
  Future<CamoResult<CamoSecuritySessionValidationDecision>> call(
    CamoSecuritySessionValidationContext context,
  ) {
    return _repository.validateSession(context);
  }
}
