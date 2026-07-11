// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_audit_batch.dart';
import '../entities/camo_audit_event.dart';
import '../entities/camo_security_event.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoAuditRepository {
  Future<CamoResult<void>> recordAuditEvent(CamoAuditEvent event);
  Future<CamoResult<void>> recordSecurityEvent(CamoSecurityEvent event);
  Future<CamoResult<void>> recordBatch(CamoAuditBatch batch);
}
