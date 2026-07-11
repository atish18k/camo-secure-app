// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_key_reference.dart';
import '../repositories/camo_kms_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RotateCamoKeyUseCase {
  const RotateCamoKeyUseCase(this._repository);
  final CamoKmsRepository _repository;
  Future<CamoResult<CamoKeyReference>> call(String keyId) {
    return _repository.rotateKey(keyId);
  }
}
