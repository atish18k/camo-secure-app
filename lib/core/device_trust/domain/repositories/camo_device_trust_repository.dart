// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_device_identity.dart';
import '../entities/camo_device_trust_decision.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoDeviceTrustRepository {
  Future<CamoResult<CamoDeviceIdentity>> registerDevice(
    CamoDeviceIdentity device,
  );
  Future<CamoResult<CamoDeviceIdentity>> approveDevice(String deviceId);
  Future<CamoResult<void>> revokeDevice(String deviceId, String reasonCode);
  Future<CamoResult<CamoDeviceTrustDecision>> validateDeviceTrust(
    String deviceId,
    String userId,
  );
}
