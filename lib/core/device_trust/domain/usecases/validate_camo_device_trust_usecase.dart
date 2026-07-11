// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_device_trust_decision.dart';
import '../repositories/camo_device_trust_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ValidateCamoDeviceTrustUseCase {
  const ValidateCamoDeviceTrustUseCase(this._repository);
  final CamoDeviceTrustRepository _repository;
  Future<CamoResult<CamoDeviceTrustDecision>> call({
    required String deviceId,
    required String userId,
  }) {
    return _repository.validateDeviceTrust(deviceId, userId);
  }
}
