// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_audit_batch.dart';
import '../repositories/camo_audit_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RecordCamoAuditBatchUseCase {
  const RecordCamoAuditBatchUseCase(this._repository);
  final CamoAuditRepository _repository;
  Future<CamoResult<void>> call(CamoAuditBatch batch) {
    return _repository.recordBatch(batch);
  }
}
