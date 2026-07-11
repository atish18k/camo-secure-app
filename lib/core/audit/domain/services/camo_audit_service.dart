// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_audit_event.dart';
import '../entities/camo_security_event.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------
abstract interface class CamoAuditService {
  Future<CamoResult<void>> record(CamoAuditEvent event);
  Future<CamoResult<void>> recordSecurity(CamoSecurityEvent event);
}
