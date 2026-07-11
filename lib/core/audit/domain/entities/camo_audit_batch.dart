// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_audit_event.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuditBatch {
  CamoAuditBatch({
    required this.batchId,
    required this.createdAt,
    required List<CamoAuditEvent> events,
  }) : events = List<CamoAuditEvent>.unmodifiable(events);
  final String batchId;
  final DateTime createdAt;
  final List<CamoAuditEvent> events;
  bool get isValid {
    return batchId.isNotEmpty &&
        events.isNotEmpty &&
        events.every((CamoAuditEvent event) => event.isValid);
  }
}
