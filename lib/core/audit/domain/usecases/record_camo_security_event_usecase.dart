// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_security_event.dart';
import '../repositories/camo_audit_repository.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class RecordCamoSecurityEventUseCase {
  const RecordCamoSecurityEventUseCase(this._repository);
  final CamoAuditRepository _repository;
  Future<CamoResult<void>> call(CamoSecurityEvent event) {
    return _repository.recordSecurityEvent(event);
  }
}
