// ignore_for_file: prefer_initializing_formals

import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/message_lifecycle/domain/entities/camo_message_validity.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/features/auth/domain/repositories/auth_repository.dart';
import 'package:camo/features/policy/domain/repositories/camo_device_identity_service.dart';

import '../../domain/services/camo_workspace_enterprise_request_builder.dart';
import '../../domain/services/camo_workspace_message_context_resolver.dart';
import '../../domain/services/camo_workspace_request_id_generator.dart';

final class DefaultCamoWorkspaceEnterpriseRequestBuilder
    implements CamoWorkspaceEnterpriseRequestBuilder {
  const DefaultCamoWorkspaceEnterpriseRequestBuilder({
    required AuthRepository authRepository,
    required CamoDeviceIdentityService deviceIdentityService,
    required CamoWorkspaceMessageContextResolver messageContextResolver,
    required CamoWorkspaceRequestIdGenerator requestIdGenerator,
    required DateTime Function() clock,
  }) : _authRepository = authRepository,
       _deviceIdentityService = deviceIdentityService,
       _messageContextResolver = messageContextResolver,
       _requestIdGenerator = requestIdGenerator,
       _clock = clock;

  final AuthRepository _authRepository;
  final CamoDeviceIdentityService _deviceIdentityService;
  final CamoWorkspaceMessageContextResolver _messageContextResolver;
  final CamoWorkspaceRequestIdGenerator _requestIdGenerator;
  final DateTime Function() _clock;

  @override
  Future<CamoEnterpriseOperationRequest> buildEncodeRequest({
    required String operationId,
    required String pairingId,
    required bool camouflageEnabled,
  }) async {
    final String normalizedOperationId = _requireValue(
      operationId,
      'Operation identifier is required.',
    );

    final String normalizedPairingId = _requireValue(
      pairingId,
      'Pairing identifier is required.',
    );

    if (camouflageEnabled) {
      throw StateError(
        'Camouflage uses a separate engine and is not active in Standard CAMO.',
      );
    }

    final String userId = _requireAuthenticatedUserId();
    final String deviceId = await _requireDeviceId();
    final DateTime requestedAt = _clock();
    final String messageId = _requireGeneratedRequestId();

    const Set<CamoEntitlementType> entitlements = <CamoEntitlementType>{
      CamoEntitlementType.baseEncoding,
    };

    return CamoEnterpriseOperationRequest(
      requestId: _requireGeneratedRequestId(),
      authorizationRequest: CamoEnterpriseAuthorizationRequest(
        operationId: normalizedOperationId,
        userId: userId,
        deviceId: deviceId,
        operationType: CamoOperationType.encode,
        keyPurpose: CamoKeyPurpose.messageEncryption,
        keyScope: CamoKeyScope.message,
        requestedAt: requestedAt,
        requiredEntitlements: entitlements,
        pairId: normalizedPairingId,
        messageId: messageId,
        messageValidity: CamoMessageValidity.oneDay,
        oneTimeView: false,
        attributes: const <String, String>{
          'source': 'workspace',
          'engine': 'standardCamo',
        },
      ),
      createdAt: requestedAt,
      payloadReference: normalizedOperationId,
      metadata: const <String, String>{
        'authorizationMode': 'freshServerAuthorization',
      },
    );
  }

  @override
  Future<CamoEnterpriseOperationRequest> buildDecodeRequest({
    required String operationId,
    required String pairingId,
  }) async {
    final String normalizedOperationId = _requireValue(
      operationId,
      'Operation identifier is required.',
    );

    final String normalizedPairingId = _requireValue(
      pairingId,
      'Pairing identifier is required.',
    );

    final String userId = _requireAuthenticatedUserId();
    final String deviceId = await _requireDeviceId();

    final String messageId = _requireValue(
      await _messageContextResolver.resolveMessageId(
        pairingId: normalizedPairingId,
        operationId: normalizedOperationId,
      ),
      'Authorized message reference is required for decoding.',
    );

    final DateTime requestedAt = _clock();

    return CamoEnterpriseOperationRequest(
      requestId: _requireGeneratedRequestId(),
      authorizationRequest: CamoEnterpriseAuthorizationRequest(
        operationId: normalizedOperationId,
        userId: userId,
        deviceId: deviceId,
        operationType: CamoOperationType.decode,
        keyPurpose: CamoKeyPurpose.messageDecryption,
        keyScope: CamoKeyScope.message,
        requestedAt: requestedAt,
        requiredEntitlements: const <CamoEntitlementType>{
          CamoEntitlementType.baseDecoding,
        },
        pairId: normalizedPairingId,
        messageId: messageId,
        attributes: const <String, String>{'source': 'workspace'},
      ),
      createdAt: requestedAt,
      payloadReference: normalizedOperationId,
      metadata: const <String, String>{
        'authorizationMode': 'freshServerAuthorization',
      },
    );
  }

  String _requireAuthenticatedUserId() {
    final String userId = _authRepository.currentUserId?.trim() ?? '';

    if (!_authRepository.isSignedIn || userId.isEmpty) {
      throw StateError(
        'Authenticated user is required for enterprise authorization.',
      );
    }

    return userId;
  }

  Future<String> _requireDeviceId() async {
    final String deviceId = (await _deviceIdentityService.getDeviceId()).trim();

    if (deviceId.isEmpty) {
      throw StateError(
        'Trusted device identifier is required for enterprise authorization.',
      );
    }

    return deviceId;
  }

  String _requireGeneratedRequestId() {
    final String requestId = _requestIdGenerator.generateRequestId().trim();

    if (requestId.isEmpty) {
      throw StateError('Enterprise request identifier generation failed.');
    }

    return requestId;
  }

  String _requireValue(String value, String failureMessage) {
    final String normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw StateError(failureMessage);
    }

    return normalizedValue;
  }
}
