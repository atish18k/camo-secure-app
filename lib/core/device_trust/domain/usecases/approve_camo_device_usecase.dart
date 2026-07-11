// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_device_identity.dart';
import '../repositories/camo_device_trust_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ApproveCamoDeviceUseCase {
  const ApproveCamoDeviceUseCase(this._repository);
  final CamoDeviceTrustRepository _repository;
  Future<CamoResult<CamoDeviceIdentity>> call(String deviceId) {
    return _repository.approveDevice(deviceId);
  }
}
