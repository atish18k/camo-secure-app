import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/message_lifecycle/domain/entities/camo_message_validity.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_outcome.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_stage.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_enterprise_operation_coordinator.dart';
import 'package:camo/core/shared/failures/camo_failure.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:camo/features/workspace/data/repositories/camo_memory_workspace_operation_payload_store.dart';
import 'package:camo/features/workspace/data/services/coordinator_backed_camo_authorized_workspace_service.dart';
import 'package:camo/features/workspace/domain/services/camo_workspace_enterprise_request_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedTime = DateTime.utc(2026, 7, 12, 12);

  test('returns authorized encode output from coordinator', () async {
    final CamoMemoryWorkspaceOperationPayloadStore payloadStore =
        CamoMemoryWorkspaceOperationPayloadStore();

    final CoordinatorBackedCamoAuthorizedWorkspaceService service =
        CoordinatorBackedCamoAuthorizedWorkspaceService(
          coordinator: _FakeCoordinator(
            result: CamoSuccess<CamoEnterpriseOperationOutcome>(
              CamoEnterpriseOperationOutcome(
                operationId: 'operation-001',
                stage: CamoEnterpriseOperationStage.completed,
                securityDecision: CamoSecurityDecision.allow,
                reasonCode: 'authorized',
                completedAt: fixedTime,
                resultReference: 'encoded-output',
              ),
            ),
          ),
          requestBuilder: _FakeRequestBuilder(fixedTime),
          payloadStore: payloadStore,
          operationIdGenerator: () => 'operation-001',
        );

    final String output = await service.encode(
      pairingId: 'pairing-001',
      plainText: 'secret',
    );

    expect(output, 'encoded-output');
    expect(payloadStore.take('operation-001'), isNull);
  });

  test(
    'fails closed when verified V2 decode coordinator is unavailable',
    () async {
      final CamoMemoryWorkspaceOperationPayloadStore payloadStore =
          CamoMemoryWorkspaceOperationPayloadStore();

      final CoordinatorBackedCamoAuthorizedWorkspaceService service =
          CoordinatorBackedCamoAuthorizedWorkspaceService(
            coordinator: _FakeCoordinator(
              result: CamoSuccess<CamoEnterpriseOperationOutcome>(
                CamoEnterpriseOperationOutcome(
                  operationId: 'operation-002',
                  stage: CamoEnterpriseOperationStage.completed,
                  securityDecision: CamoSecurityDecision.allow,
                  reasonCode: 'authorized',
                  completedAt: fixedTime,
                  resultReference: 'decoded-output',
                ),
              ),
            ),
            requestBuilder: _FakeRequestBuilder(fixedTime),
            payloadStore: payloadStore,
            operationIdGenerator: () => 'operation-002',
          );

      await expectLater(
        service.decode(pairingId: 'pairing-001', encodedText: 'encoded-input'),
        throwsA(
          isA<StateError>().having(
            (StateError error) => error.message,
            'message',
            'Verified V2 Standard UNCAMO coordinator is unavailable.',
          ),
        ),
      );
      expect(payloadStore.take('operation-002'), isNull);
    },
  );

  test('removes sensitive payload when coordinator denies operation', () async {
    final CamoMemoryWorkspaceOperationPayloadStore payloadStore =
        CamoMemoryWorkspaceOperationPayloadStore();

    final CoordinatorBackedCamoAuthorizedWorkspaceService service =
        CoordinatorBackedCamoAuthorizedWorkspaceService(
          coordinator: const _FakeCoordinator(
            result: CamoError<CamoEnterpriseOperationOutcome>(
              CamoSecurityFailure(
                code: 'authorization_denied',
                message: 'Authorization denied.',
              ),
            ),
          ),
          requestBuilder: _FakeRequestBuilder(fixedTime),
          payloadStore: payloadStore,
          operationIdGenerator: () => 'operation-003',
        );

    await expectLater(
      service.encode(pairingId: 'pairing-001', plainText: 'secret'),
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          'Authorization denied.',
        ),
      ),
    );

    expect(payloadStore.take('operation-003'), isNull);
  });

  test('fails closed when request operation id does not match', () async {
    final CamoMemoryWorkspaceOperationPayloadStore payloadStore =
        CamoMemoryWorkspaceOperationPayloadStore();

    final CoordinatorBackedCamoAuthorizedWorkspaceService service =
        CoordinatorBackedCamoAuthorizedWorkspaceService(
          coordinator: const _FakeCoordinator(
            result: CamoError<CamoEnterpriseOperationOutcome>(
              CamoSecurityFailure(
                code: 'must_not_execute',
                message: 'Coordinator must not execute.',
              ),
            ),
          ),
          requestBuilder: _FakeRequestBuilder(
            fixedTime,
            forceOperationId: 'different-operation',
          ),
          payloadStore: payloadStore,
          operationIdGenerator: () => 'operation-004',
        );

    await expectLater(
      service.encode(pairingId: 'pairing-001', plainText: 'secret'),
      throwsA(isA<StateError>()),
    );

    expect(payloadStore.take('operation-004'), isNull);
  });
}

final class _FakeRequestBuilder
    implements CamoWorkspaceEnterpriseRequestBuilder {
  const _FakeRequestBuilder(this.fixedTime, {this.forceOperationId});

  final DateTime fixedTime;
  final String? forceOperationId;

  @override
  Future<CamoEnterpriseOperationRequest> buildEncodeRequest({
    required String operationId,
    required String pairingId,
    required bool camouflageEnabled,
  }) async {
    return _build(
      operationId: forceOperationId ?? operationId,
      pairingId: pairingId,
      operationType: CamoOperationType.encode,
      keyPurpose: CamoKeyPurpose.messageEncryption,
      entitlement: camouflageEnabled
          ? CamoEntitlementType.camouflage
          : CamoEntitlementType.baseEncoding,
    );
  }

  @override
  Future<CamoEnterpriseOperationRequest> buildDecodeRequest({
    required String operationId,
    required String pairingId,
  }) async {
    return _build(
      operationId: forceOperationId ?? operationId,
      pairingId: pairingId,
      operationType: CamoOperationType.decode,
      keyPurpose: CamoKeyPurpose.messageDecryption,
      entitlement: CamoEntitlementType.baseDecoding,
    );
  }

  CamoEnterpriseOperationRequest _build({
    required String operationId,
    required String pairingId,
    required CamoOperationType operationType,
    required CamoKeyPurpose keyPurpose,
    required CamoEntitlementType entitlement,
  }) {
    final bool isEncode = operationType == CamoOperationType.encode;

    return CamoEnterpriseOperationRequest(
      requestId: 'request-$operationId',
      authorizationRequest: CamoEnterpriseAuthorizationRequest(
        operationId: operationId,
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: operationType,
        keyPurpose: keyPurpose,
        keyScope: CamoKeyScope.message,
        requestedAt: fixedTime,
        requiredEntitlements: <CamoEntitlementType>{entitlement},
        pairId: pairingId,
        messageId: 'message-001',
        messageValidity: isEncode ? CamoMessageValidity.oneDay : null,
        oneTimeView: isEncode ? false : null,
      ),
      createdAt: fixedTime,
    );
  }
}

final class _FakeCoordinator implements CamoEnterpriseOperationCoordinator {
  const _FakeCoordinator({required this.result});

  final CamoResult<CamoEnterpriseOperationOutcome> result;

  @override
  Future<CamoResult<CamoEnterpriseOperationOutcome>> coordinate(
    CamoEnterpriseOperationRequest request,
  ) async {
    return result;
  }
}
