// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../../../../core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import '../../../../core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import '../../../../core/shared/result/camo_result.dart';
import '../../../../core/shared/types/camo_operation_type.dart';

typedef CamoVerifiedV2AuthorizationCall =
    Future<CamoResult<CamoSignedAuthorizationContractV2>> Function({
      required Map<String, Object?> payload,
      required String expectedRequestId,
    });

typedef CamoVerifiedV2WorkspaceDecrypt =
    Future<String> Function({
      required String requestId,
      required String operationId,
      required String messageId,
      required String pairingId,
      required String encodedText,
    });

final class CamoVerifiedV2WorkspaceDecodeCoordinator {
  const CamoVerifiedV2WorkspaceDecodeCoordinator({
    required CamoVerifiedV2AuthorizationCall authorize,
    required CamoVerifiedV2WorkspaceDecrypt decrypt,
  }) : _authorize = authorize,
       _decrypt = decrypt;

  final CamoVerifiedV2AuthorizationCall _authorize;
  final CamoVerifiedV2WorkspaceDecrypt _decrypt;

  Future<String> decode({
    required String requestId,
    required CamoEnterpriseAuthorizationRequest authorization,
    required String encodedText,
  }) async {
    final String normalizedRequestId = requestId.trim();
    final String normalizedEncodedText = encodedText.trim();
    final String operationId = authorization.operationId.trim();
    final String userId = authorization.userId.trim();
    final String deviceId = authorization.deviceId.trim();
    final String pairId = authorization.pairId?.trim() ?? '';
    final String messageId = authorization.messageId?.trim() ?? '';

    if (normalizedRequestId.isEmpty ||
        normalizedEncodedText.isEmpty ||
        !authorization.isValid ||
        authorization.operationType != CamoOperationType.decode ||
        operationId.isEmpty ||
        userId.isEmpty ||
        deviceId.isEmpty ||
        pairId.isEmpty ||
        messageId.isEmpty) {
      throw StateError('Verified V2 UNCAMO request is invalid.');
    }

    final Hash digest = await Sha256().hash(utf8.encode(normalizedEncodedText));
    final String payloadDigest = digest.bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    final Map<String, Object?> payload =
        Map<String, Object?>.unmodifiable(<String, Object?>{
          'requestId': normalizedRequestId,
          'operationId': operationId,
          'userId': userId,
          'deviceId': deviceId,
          'operationType': authorization.operationType.name,
          'keyPurpose': authorization.keyPurpose.name,
          'keyScope': authorization.keyScope.name,
          'requestedAt': authorization.requestedAt.toUtc().toIso8601String(),
          'payloadDigest': payloadDigest,
          'pairId': pairId,
          'messageId': messageId,
          'requiredEntitlements': authorization.requiredEntitlements
              .map((entitlement) => entitlement.name)
              .toList(growable: false),
          'attributes': authorization.attributes,
        });

    final CamoResult<CamoSignedAuthorizationContractV2> result =
        await _authorize(
          payload: payload,
          expectedRequestId: normalizedRequestId,
        );

    if (result.isFailure) {
      throw StateError(
        result.failureOrNull?.message ??
            'Verified V2 server authorization failed.',
      );
    }

    final CamoSignedAuthorizationContractV2? contract = result.valueOrNull;

    if (contract == null ||
        contract.requestId != normalizedRequestId ||
        contract.operationId != operationId ||
        contract.userId != userId ||
        contract.deviceId != deviceId ||
        contract.pairId != pairId ||
        contract.messageId != messageId ||
        contract.payloadDigest != payloadDigest) {
      throw StateError('Verified V2 authorization binding failed.');
    }

    return _decrypt(
      requestId: normalizedRequestId,
      operationId: operationId,
      messageId: messageId,
      pairingId: pairId,
      encodedText: normalizedEncodedText,
    );
  }
}
