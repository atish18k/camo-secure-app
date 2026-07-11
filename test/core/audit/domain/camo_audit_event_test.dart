// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/audit/domain/entities/camo_audit_category.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_correlation.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_event.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_identity.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_outcome.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_severity.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('valid audit event exposes valid state', () {
    final CamoAuditEvent event = CamoAuditEvent(
      eventId: 'event-001',
      eventType: 'authorization_allowed',
      category: CamoAuditCategory.authorization,
      severity: CamoAuditSeverity.info,
      outcome: CamoAuditOutcome.success,
      identity: const CamoAuditIdentity(
        userId: 'user-001',
        deviceId: 'device-001',
      ),
      correlation: const CamoAuditCorrelation(
        correlationId: 'correlation-001',
        traceId: 'trace-001',
        operationId: 'operation-001',
      ),
      occurredAt: DateTime.now(),
      source: 'authorization-service',
      reasonCode: 'authorization_allowed',
    );
    expect(event.isValid, isTrue);
  });
}
