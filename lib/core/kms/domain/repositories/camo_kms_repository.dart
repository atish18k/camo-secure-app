// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_key_reference.dart';
import '../entities/camo_key_release_context.dart';
import '../entities/camo_key_release_decision.dart';
import '../entities/camo_wrapped_key_material.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoKmsRepository {
  Future<CamoResult<CamoKeyReleaseDecision>> authorizeKeyRelease(
    CamoKeyReleaseContext context,
  );
  Future<CamoResult<CamoWrappedKeyMaterial>> releaseWrappedKey(
    CamoKeyReleaseDecision decision,
  );
  Future<CamoResult<void>> consumeKeyRelease(String releaseId);
  Future<CamoResult<CamoKeyReference>> rotateKey(String keyId);
  Future<CamoResult<void>> revokeKey(String keyId, String reasonCode);
}
