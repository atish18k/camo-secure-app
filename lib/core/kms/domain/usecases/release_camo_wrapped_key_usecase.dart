// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_key_release_decision.dart';
import '../entities/camo_wrapped_key_material.dart';
import '../repositories/camo_kms_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ReleaseCamoWrappedKeyUseCase {
  const ReleaseCamoWrappedKeyUseCase(this._repository);
  final CamoKmsRepository _repository;
  Future<CamoResult<CamoWrappedKeyMaterial>> call(
    CamoKeyReleaseDecision decision,
  ) {
    return _repository.releaseWrappedKey(decision);
  }
}
