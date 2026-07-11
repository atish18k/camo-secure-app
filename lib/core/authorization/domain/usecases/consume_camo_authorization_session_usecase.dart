// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../services/camo_enterprise_authorization_service.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ConsumeCamoAuthorizationSessionUseCase {
  const ConsumeCamoAuthorizationSessionUseCase(this._service);
  final CamoEnterpriseAuthorizationService _service;
  Future<CamoResult<void>> call(String sessionId) {
    return _service.consumeSession(sessionId);
  }
}
