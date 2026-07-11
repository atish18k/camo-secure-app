// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_security_session_termination_reason.dart';
import '../repositories/camo_security_session_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RevokeCamoSecuritySessionUseCase {
  const RevokeCamoSecuritySessionUseCase(this._repository);
  final CamoSecuritySessionRepository _repository;
  Future<CamoResult<void>> call({
    required String sessionId,
    required CamoSecuritySessionTerminationReason reason,
  }) {
    return _repository.revokeSession(sessionId: sessionId, reason: reason);
  }
}
