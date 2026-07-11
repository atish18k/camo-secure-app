// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../repositories/camo_kms_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class ConsumeCamoKeyReleaseUseCase {
  const ConsumeCamoKeyReleaseUseCase(this._repository);
  final CamoKmsRepository _repository;
  Future<CamoResult<void>> call(String releaseId) {
    return _repository.consumeKeyRelease(releaseId);
  }
}
