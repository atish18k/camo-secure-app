// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_outcome.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_stage.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('completed allowed outcome is successful', () {
    final CamoEnterpriseOperationOutcome outcome =
        CamoEnterpriseOperationOutcome(
          operationId: 'operation-001',
          stage: CamoEnterpriseOperationStage.completed,
          securityDecision: CamoSecurityDecision.allow,
          reasonCode: 'operation_completed',
          completedAt: DateTime.now(),
          resultReference: 'result-001',
        );
    expect(outcome.isSuccessful, isTrue);
  });
}
