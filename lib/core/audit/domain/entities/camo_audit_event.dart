// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_audit_category.dart';
import 'camo_audit_correlation.dart';
import 'camo_audit_identity.dart';
import 'camo_audit_outcome.dart';
import 'camo_audit_severity.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuditEvent {
  CamoAuditEvent({
    required this.eventId,
    required this.eventType,
    required this.category,
    required this.severity,
    required this.outcome,
    required this.identity,
    required this.correlation,
    required this.occurredAt,
    required this.source,
    required this.reasonCode,
    Map<String, String> attributes = const <String, String>{},
  }) : attributes = Map<String, String>.unmodifiable(attributes);
  final String eventId;
  final String eventType;
  final CamoAuditCategory category;
  final CamoAuditSeverity severity;
  final CamoAuditOutcome outcome;
  final CamoAuditIdentity identity;
  final CamoAuditCorrelation correlation;
  final DateTime occurredAt;
  final String source;
  final String reasonCode;
  final Map<String, String> attributes;
  bool get isValid {
    return eventId.isNotEmpty &&
        eventType.isNotEmpty &&
        identity.isValid &&
        correlation.isValid &&
        source.isNotEmpty &&
        reasonCode.isNotEmpty;
  }
}
