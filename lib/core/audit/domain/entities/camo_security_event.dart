// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_audit_event.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoSecurityEvent {
  const CamoSecurityEvent({
    required this.auditEvent,
    required this.threatDetected,
    required this.requiresResponse,
    this.incidentReference,
  });
  final CamoAuditEvent auditEvent;
  final bool threatDetected;
  final bool requiresResponse;
  final String? incidentReference;
  bool get requiresImmediateResponse {
    final String severityName = auditEvent.severity.name.toLowerCase();

    final bool requiresImmediateAttention =
        severityName == 'critical' || severityName == 'high';

    return requiresImmediateAttention && threatDetected && requiresResponse;
  }
}
