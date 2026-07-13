import 'package:camo/core/authorization/data/services/default_camo_enterprise_authorization_operation_request_mapper.dart';
import 'package:camo/core/authorization/data/services/fail_closed_camo_authorization_pipeline_decision_factory.dart';
import 'package:camo/core/authorization/data/services/pipeline_backed_camo_enterprise_authorization_service.dart';
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_reference.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_context.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_decision.dart';
import 'package:camo/core/kms/domain/entities/camo_wrapped_key_material.dart';
import 'package:camo/core/kms/domain/repositories/camo_kms_repository.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/operation_coordinator/data/services/fail_closed_camo_enterprise_security_pipeline_ports.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_execution_context.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_outcome.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_authorized_operation_executor.dart';
import 'package:camo/core/operation_coordinator/domain/services/default_camo_enterprise_operation_coordinator.dart';
import 'package:camo/core/operation_coordinator/domain/services/default_camo_enterprise_security_pipeline.dart';
import 'package:camo/core/shared/failures/camo_failure.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TrackingKmsRepository implements CamoKmsRepository {
  int authorizeCalls = 0;
  int releaseCalls = 0;
  int consumeCalls = 0;
  int rotateCalls = 0;
  int revokeCalls = 0;

  @override
  Future<CamoResult<CamoKeyReleaseDecision>> authorizeKeyRelease(
    CamoKeyReleaseContext context,
  ) async {
    authorizeCalls++;

    return const CamoError<CamoKeyReleaseDecision>(
      CamoSecurityFailure(
        code: 'test_kms_must_not_be_reached',
        message: 'KMS authorization must not be reached.',
      ),
    );
  }

  @override
  Future<CamoResult<CamoWrappedKeyMaterial>> releaseWrappedKey(
    CamoKeyReleaseDecision decision,
  ) async {
    releaseCalls++;

    return const CamoError<CamoWrappedKeyMaterial>(
      CamoSecurityFailure(
        code: 'test_kms_release_must_not_be_reached',
        message: 'KMS release must not be reached.',
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeKeyRelease(String releaseId) async {
    consumeCalls++;

    return const CamoError<void>(
      CamoSecurityFailure(
        code: 'test_kms_consume_must_not_be_reached',
        message: 'KMS consumption must not be reached.',
      ),
    );
  }

  @override
  Future<CamoResult<CamoKeyReference>> rotateKey(String keyId) async {
    rotateCalls++;

    return const CamoError<CamoKeyReference>(
      CamoSecurityFailure(
        code: 'test_kms_rotate_must_not_be_reached',
        message: 'KMS rotation must not be reached.',
      ),
    );
  }

  @override
  Future<CamoResult<void>> revokeKey(String keyId, String reasonCode) async {
    revokeCalls++;

    return const CamoError<void>(
      CamoSecurityFailure(
        code: 'test_kms_revoke_must_not_be_reached',
        message: 'KMS revocation must not be reached.',
      ),
    );
  }
}

final class _TrackingAuthorizedOperationExecutor
    implements CamoAuthorizedOperationExecutor {
  int executeCalls = 0;

  @override
  Future<CamoResult<CamoEnterpriseOperationOutcome>> execute(
    CamoEnterpriseOperationExecutionContext context,
  ) async {
    executeCalls++;

    return const CamoError<CamoEnterpriseOperationOutcome>(
      CamoSecurityFailure(
        code: 'test_executor_must_not_be_reached',
        message: 'Authorized executor must not be reached.',
      ),
    );
  }
}

void main() {
  test(
    'concrete runtime chain denies before KMS release and execution',
    () async {
      final DateTime now = DateTime.utc(2026, 7, 13);

      final _TrackingKmsRepository kmsRepository = _TrackingKmsRepository();

      final _TrackingAuthorizedOperationExecutor executor =
          _TrackingAuthorizedOperationExecutor();

      final PipelineBackedCamoEnterpriseAuthorizationService
      authorizationService = PipelineBackedCamoEnterpriseAuthorizationService(
        pipeline: DefaultCamoEnterpriseSecurityPipeline(
          securitySessionPort:
              const FailClosedCamoSecuritySessionCoordinatorPort(),
          authorizationGatewayPort:
              const FailClosedCamoAuthorizationGatewayCoordinatorPort(),
          authorizationPort: const FailClosedCamoAuthorizationCoordinatorPort(),
          policyPort: const FailClosedCamoPolicyCoordinatorPort(),
          deviceTrustPort: const FailClosedCamoDeviceTrustCoordinatorPort(),
          riskPort: const FailClosedCamoRiskCoordinatorPort(),
          licensingPort: const FailClosedCamoLicensingCoordinatorPort(),
          kmsPort: const FailClosedCamoKmsCoordinatorPort(),
          auditPort: const FailClosedCamoAuditCoordinatorPort(),
          clock: () => now,
          authorizationReferenceGenerator: () => 'authorization-001',
        ),
        requestMapper: DefaultCamoEnterpriseAuthorizationOperationRequestMapper(
          requestIdGenerator: () => 'mapped-request-001',
          clock: () => now,
        ),
        decisionFactory:
            const FailClosedCamoAuthorizationPipelineDecisionFactory(),
      );

      final DefaultCamoEnterpriseOperationCoordinator coordinator =
          DefaultCamoEnterpriseOperationCoordinator(
            authorizationService: authorizationService,
            kmsRepository: kmsRepository,
            executor: executor,
          );

      final CamoEnterpriseAuthorizationRequest authorizationRequest =
          CamoEnterpriseAuthorizationRequest(
            operationId: 'operation-001',
            userId: 'user-001',
            deviceId: 'device-001',
            operationType: CamoOperationType.encode,
            keyPurpose: CamoKeyPurpose.messageEncryption,
            keyScope: CamoKeyScope.message,
            requestedAt: now,
            requiredEntitlements: const <CamoEntitlementType>{
              CamoEntitlementType.baseEncoding,
            },
            pairId: 'pair-001',
          );

      final CamoEnterpriseOperationRequest operationRequest =
          CamoEnterpriseOperationRequest(
            requestId: 'workspace-request-001',
            authorizationRequest: authorizationRequest,
            createdAt: now,
            payloadReference: 'operation-001',
          );

      final CamoResult<CamoEnterpriseOperationOutcome> result =
          await coordinator.coordinate(operationRequest);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'enterprise_security_pipeline_denied');

      expect(kmsRepository.authorizeCalls, 0);
      expect(kmsRepository.releaseCalls, 0);
      expect(kmsRepository.consumeCalls, 0);
      expect(kmsRepository.rotateCalls, 0);
      expect(kmsRepository.revokeCalls, 0);
      expect(executor.executeCalls, 0);
    },
  );
}
