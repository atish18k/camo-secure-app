// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../repositories/camo_kms_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RevokeCamoKeyUseCase {
  const RevokeCamoKeyUseCase(this._repository);
  final CamoKmsRepository _repository;
  Future<CamoResult<void>> call({
    required String keyId,
    required String reasonCode,
  }) {
    return _repository.revokeKey(keyId, reasonCode);
  }
}
