// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_outcome.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_stage.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_enterprise_operation_coordinator.dart';
import 'package:camo/core/operation_coordinator/domain/usecases/coordinate_camo_enterprise_operation_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Coordinator
// -----------------------------------------------------------------------------
final class _FakeOperationCoordinator
    implements CamoEnterpriseOperationCoordinator {
  @override
  Future<CamoResult<CamoEnterpriseOperationOutcome>> coordinate(
    CamoEnterpriseOperationRequest request,
  ) async {
    return CamoSuccess<CamoEnterpriseOperationOutcome>(
      CamoEnterpriseOperationOutcome(
        operationId: request.authorizationRequest.operationId,
        stage: CamoEnterpriseOperationStage.completed,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'operation_completed',
        completedAt: DateTime.now(),
        resultReference: 'result-001',
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('coordinator use case delegates request', () async {
    final CoordinateCamoEnterpriseOperationUseCase useCase =
        CoordinateCamoEnterpriseOperationUseCase(_FakeOperationCoordinator());
    final CamoEnterpriseOperationRequest request =
        CamoEnterpriseOperationRequest(
          requestId: 'request-001',
          authorizationRequest: CamoEnterpriseAuthorizationRequest(
            operationId: 'operation-001',
            userId: 'user-001',
            deviceId: 'device-001',
            operationType: CamoOperationType.decode,
            keyPurpose: CamoKeyPurpose.messageDecryption,
            keyScope: CamoKeyScope.message,
            requestedAt: DateTime.now(),
            requiredEntitlements: const <CamoEntitlementType>{
              CamoEntitlementType.baseDecoding,
            },
            messageId: 'message-001',
          ),
          createdAt: DateTime.now(),
        );
    final CamoResult<CamoEnterpriseOperationOutcome> result = await useCase(
      request,
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.isSuccessful, isTrue);
  });
}
