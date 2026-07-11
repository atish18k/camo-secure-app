// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../repositories/camo_security_session_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ConsumeCamoSecuritySessionUseCase {
  const ConsumeCamoSecuritySessionUseCase(this._repository);
  final CamoSecuritySessionRepository _repository;
  Future<CamoResult<void>> call(String sessionId) {
    return _repository.consumeSession(sessionId);
  }
}
