// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../repositories/camo_device_trust_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RevokeCamoDeviceUseCase {
  const RevokeCamoDeviceUseCase(this._repository);
  final CamoDeviceTrustRepository _repository;
  Future<CamoResult<void>> call({
    required String deviceId,
    required String reasonCode,
  }) {
    return _repository.revokeDevice(deviceId, reasonCode);
  }
}
