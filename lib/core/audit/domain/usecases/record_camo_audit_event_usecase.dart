// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_audit_event.dart';
import '../repositories/camo_audit_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RecordCamoAuditEventUseCase {
  const RecordCamoAuditEventUseCase(this._repository);
  final CamoAuditRepository _repository;
  Future<CamoResult<void>> call(CamoAuditEvent event) {
    return _repository.recordAuditEvent(event);
  }
}
