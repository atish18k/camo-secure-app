// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_security_session.dart';
import '../repositories/camo_security_session_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class CreateCamoSecuritySessionUseCase {
  const CreateCamoSecuritySessionUseCase(this._repository);
  final CamoSecuritySessionRepository _repository;
  Future<CamoResult<CamoSecuritySession>> call(CamoSecuritySession session) {
    return _repository.createSession(session);
  }
}
