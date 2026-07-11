// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/audit/domain/entities/camo_audit_batch.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_category.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_correlation.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_event.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_identity.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_outcome.dart';
import 'package:camo/core/audit/domain/entities/camo_audit_severity.dart';
import 'package:camo/core/audit/domain/entities/camo_security_event.dart';
import 'package:camo/core/audit/domain/repositories/camo_audit_repository.dart';
import 'package:camo/core/audit/domain/usecases/record_camo_audit_event_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeAuditRepository implements CamoAuditRepository {
  @override
  Future<CamoResult<void>> recordAuditEvent(CamoAuditEvent event) async {
    return const CamoSuccess<void>(null);
  }

  @override
  Future<CamoResult<void>> recordSecurityEvent(CamoSecurityEvent event) async {
    return const CamoSuccess<void>(null);
  }

  @override
  Future<CamoResult<void>> recordBatch(CamoAuditBatch batch) async {
    return const CamoSuccess<void>(null);
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('record audit event use case delegates to repository', () async {
    final RecordCamoAuditEventUseCase useCase = RecordCamoAuditEventUseCase(
      _FakeAuditRepository(),
    );
    final CamoAuditEvent event = CamoAuditEvent(
      eventId: 'event-001',
      eventType: 'operation_completed',
      category: CamoAuditCategory.operation,
      severity: CamoAuditSeverity.info,
      outcome: CamoAuditOutcome.success,
      identity: const CamoAuditIdentity(
        userId: 'user-001',
        deviceId: 'device-001',
      ),
      correlation: const CamoAuditCorrelation(
        correlationId: 'correlation-001',
        traceId: 'trace-001',
      ),
      occurredAt: DateTime.now(),
      source: 'operation-coordinator',
      reasonCode: 'operation_completed',
    );
    final CamoResult<void> result = await useCase(event);
    expect(result.isSuccess, isTrue);
  });
}
