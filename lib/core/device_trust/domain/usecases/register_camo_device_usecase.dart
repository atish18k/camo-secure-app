// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_device_identity.dart';
import '../repositories/camo_device_trust_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RegisterCamoDeviceUseCase {
  const RegisterCamoDeviceUseCase(this._repository);
  final CamoDeviceTrustRepository _repository;
  Future<CamoResult<CamoDeviceIdentity>> call(CamoDeviceIdentity device) {
    return _repository.registerDevice(device);
  }
}
