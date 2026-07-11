// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_context.dart';
import '../entities/camo_authorization_decision.dart';
import '../repositories/camo_authorization_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class AuthorizeCamoOperationUseCase {
  const AuthorizeCamoOperationUseCase(this._repository);
  final CamoAuthorizationRepository _repository;
  Future<CamoResult<CamoAuthorizationDecision>> call(
    CamoAuthorizationContext context,
  ) {
    return _repository.authorizeOperation(context);
  }
}
