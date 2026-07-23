// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_outcome.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_enterprise_operation_coordinator.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:cryptography/cryptography.dart';

import '../../domain/entities/camo_workspace_operation_payload.dart';
import '../../domain/repositories/camo_workspace_operation_payload_store.dart';
import '../../domain/services/camo_authorized_workspace_service.dart';
import '../../domain/services/camo_workspace_enterprise_request_builder.dart';
import 'camo_verified_v2_workspace_decode_coordinator.dart';

final class CoordinatorBackedCamoAuthorizedWorkspaceService
    implements CamoAuthorizedWorkspaceService {
  const CoordinatorBackedCamoAuthorizedWorkspaceService({
    required CamoEnterpriseOperationCoordinator coordinator,
    required CamoWorkspaceEnterpriseRequestBuilder requestBuilder,
    required CamoWorkspaceOperationPayloadStore payloadStore,
    required String Function() operationIdGenerator,
    CamoVerifiedV2WorkspaceDecodeCoordinator? verifiedV2DecodeCoordinator,
  }) : _coordinator = coordinator,
       _requestBuilder = requestBuilder,
       _payloadStore = payloadStore,
       _operationIdGenerator = operationIdGenerator,
       _verifiedV2DecodeCoordinator = verifiedV2DecodeCoordinator;

  final CamoEnterpriseOperationCoordinator _coordinator;
  final CamoWorkspaceEnterpriseRequestBuilder _requestBuilder;
  final CamoWorkspaceOperationPayloadStore _payloadStore;
  final String Function() _operationIdGenerator;
  final CamoVerifiedV2WorkspaceDecodeCoordinator? _verifiedV2DecodeCoordinator;

  @override
  Future<String> encode({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    final String operationId = _createOperationId();

    final CamoWorkspaceOperationPayload payload = CamoWorkspaceOperationPayload(
      operationId: operationId,
      pairingId: pairingId,
      operationType: CamoOperationType.encode,
      plainText: plainText,
      subject: subject,
      camouflageEnabled: camouflageEnabled,
    );

    _payloadStore.put(payload);

    try {
      final CamoEnterpriseOperationRequest baseRequest = await _requestBuilder
          .buildEncodeRequest(
            operationId: operationId,
            pairingId: pairingId,
            camouflageEnabled: camouflageEnabled,
          );

      final CamoEnterpriseOperationRequest request =
          await _bindStandardCamoPayloadDigest(
            request: baseRequest,
            plainText: plainText,
          );

      return await _coordinate(operationId: operationId, request: request);
    } finally {
      _payloadStore.remove(operationId);
    }
  }

  @override
  Future<String> decode({
    required String pairingId,
    required String encodedText,
  }) async {
    final String operationId = _createOperationId();

    final CamoWorkspaceOperationPayload payload = CamoWorkspaceOperationPayload(
      operationId: operationId,
      pairingId: pairingId,
      operationType: CamoOperationType.decode,
      encodedText: encodedText,
    );

    _payloadStore.put(payload);

    try {
      final CamoEnterpriseOperationRequest request = await _requestBuilder
          .buildDecodeRequest(operationId: operationId, pairingId: pairingId);
      final CamoVerifiedV2WorkspaceDecodeCoordinator? coordinator =
          _verifiedV2DecodeCoordinator;

      if (coordinator == null) {
        throw StateError(
          'Verified V2 Standard UNCAMO coordinator is unavailable.',
        );
      }

      return coordinator.decode(
        requestId: request.requestId,
        authorization: request.authorizationRequest,
        encodedText: encodedText,
      );
    } finally {
      _payloadStore.remove(operationId);
    }
  }

  Future<CamoEnterpriseOperationRequest> _bindStandardCamoPayloadDigest({
    required CamoEnterpriseOperationRequest request,
    required String plainText,
  }) async {
    final CamoEnterpriseAuthorizationRequest authorization =
        request.authorizationRequest;
    final Hash digest = await Sha256().hash(utf8.encode(plainText));
    final String payloadDigest = digest.bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    final CamoEnterpriseAuthorizationRequest boundAuthorization =
        CamoEnterpriseAuthorizationRequest(
          operationId: authorization.operationId,
          userId: authorization.userId,
          deviceId: authorization.deviceId,
          operationType: authorization.operationType,
          keyPurpose: authorization.keyPurpose,
          keyScope: authorization.keyScope,
          requestedAt: authorization.requestedAt,
          requiredEntitlements: authorization.requiredEntitlements,
          pairId: authorization.pairId,
          messageId: authorization.messageId,
          messageValidity: authorization.messageValidity,
          oneTimeView: authorization.oneTimeView,
          payloadDigest: payloadDigest,
          attributes: authorization.attributes,
        );

    if (!boundAuthorization.hasStandardCamoEncodeContract) {
      throw StateError('Standard CAMO authorization contract is incomplete.');
    }

    return CamoEnterpriseOperationRequest(
      requestId: request.requestId,
      authorizationRequest: boundAuthorization,
      createdAt: request.createdAt,
      payloadReference: request.payloadReference,
      metadata: request.metadata,
    );
  }

  String _createOperationId() {
    final String operationId = _operationIdGenerator().trim();

    if (operationId.isEmpty) {
      throw StateError('Operation identifier generation failed.');
    }

    return operationId;
  }

  Future<String> _coordinate({
    required String operationId,
    required CamoEnterpriseOperationRequest request,
  }) async {
    if (request.authorizationRequest.operationId != operationId) {
      throw StateError('Enterprise request operation identifier mismatch.');
    }

    final CamoResult<CamoEnterpriseOperationOutcome> result = await _coordinator
        .coordinate(request);

    if (result.isFailure) {
      throw StateError(
        result.failureOrNull?.message ??
            'Enterprise operation authorization failed.',
      );
    }

    final CamoEnterpriseOperationOutcome? outcome = result.valueOrNull;
    final String output = outcome?.resultReference?.trim() ?? '';

    if (outcome == null || !outcome.isSuccessful || output.isEmpty) {
      throw StateError('Enterprise operation did not return a valid result.');
    }

    return output;
  }
}
