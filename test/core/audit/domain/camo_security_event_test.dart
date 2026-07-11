// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/audit/domain/entities/camo_audit_category.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_correlation.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_event.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_identity.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_outcome.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_severity.dart';
import 'package:camo/core/audit/domain/entities/camo_security_event.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('critical threat requires immediate response', () {
    final CamoSecurityEvent event = CamoSecurityEvent(
      auditEvent: CamoAuditEvent(
        eventId: 'event-001',
        eventType: 'runtime_tamper_detected',
        category: CamoAuditCategory.runtimeIntegrity,
        severity: CamoAuditSeverity.critical,
        outcome: CamoAuditOutcome.blocked,
        identity: const CamoAuditIdentity(
          userId: 'user-001',
          deviceId: 'device-001',
        ),
        correlation: const CamoAuditCorrelation(
          correlationId: 'correlation-001',
          traceId: 'trace-001',
        ),
        occurredAt: DateTime.now(),
        source: 'runtime-integrity',
        reasonCode: 'tamper_detected',
      ),
      threatDetected: true,
      requiresResponse: true,
    );
    expect(event.requiresImmediateResponse, isTrue);
  });
}
