import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/features/workspace/data/services/camo_verified_v2_workspace_decode_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds exact decode payload and forwards verified bindings', () async {
    Map<String, Object?>? capturedPayload;
    String? capturedRequestId;
    Map<String, String>? decryptBindings;

    final CamoVerifiedV2WorkspaceDecodeCoordinator coordinator =
        CamoVerifiedV2WorkspaceDecodeCoordinator(
          authorize:
              ({
                required Map<String, Object?> payload,
                required String expectedRequestId,
              }) async {
                capturedPayload = payload;
                capturedRequestId = expectedRequestId;
                return CamoSuccess<CamoSignedAuthorizationContractV2>(
                  _contract(
                    requestId: expectedRequestId,
                    operationId: payload['operationId']! as String,
                    userId: payload['userId']! as String,
                    deviceId: payload['deviceId']! as String,
                    pairId: payload['pairId']! as String,
                    messageId: payload['messageId']! as String,
                    payloadDigest: payload['payloadDigest']! as String,
                  ),
                );
              },
          decrypt:
              ({
                required String requestId,
                required String operationId,
                required String messageId,
                required String pairingId,
                required String encodedText,
              }) async {
                decryptBindings = <String, String>{
                  'requestId': requestId,
                  'operationId': operationId,
                  'messageId': messageId,
                  'pairId': pairingId,
                  'encodedText': encodedText,
                };
                return 'plain-text';
              },
        );

    final String output = await coordinator.decode(
      requestId: 'request-1',
      authorization: _authorization(),
      encodedText: 'CAMO-V2-ENCODED',
    );

    expect(output, 'plain-text');
    expect(capturedRequestId, 'request-1');
    expect(capturedPayload?['operationType'], 'decode');
    expect(
      capturedPayload?['payloadDigest'],
      matches(RegExp(r'^[a-f0-9]{64}$')),
    );
    expect(capturedPayload?.containsKey('messageValidity'), isFalse);
    expect(capturedPayload?.containsKey('oneTimeView'), isFalse);
    expect(decryptBindings?['requestId'], 'request-1');
    expect(decryptBindings?['operationId'], 'operation-1');
    expect(decryptBindings?['messageId'], 'message-1');
    expect(decryptBindings?['pairId'], 'pair-1');
  });

  test('fails closed when signed contract binding differs', () async {
    bool decryptCalled = false;

    final CamoVerifiedV2WorkspaceDecodeCoordinator coordinator =
        CamoVerifiedV2WorkspaceDecodeCoordinator(
          authorize:
              ({
                required Map<String, Object?> payload,
                required String expectedRequestId,
              }) async {
                return CamoSuccess<CamoSignedAuthorizationContractV2>(
                  _contract(
                    requestId: expectedRequestId,
                    operationId: 'different-operation',
                    userId: payload['userId']! as String,
                    deviceId: payload['deviceId']! as String,
                    pairId: payload['pairId']! as String,
                    messageId: payload['messageId']! as String,
                    payloadDigest: payload['payloadDigest']! as String,
                  ),
                );
              },
          decrypt:
              ({
                required String requestId,
                required String operationId,
                required String messageId,
                required String pairingId,
                required String encodedText,
              }) async {
                decryptCalled = true;
                return 'must-not-run';
              },
        );

    await expectLater(
      coordinator.decode(
        requestId: 'request-1',
        authorization: _authorization(),
        encodedText: 'CAMO-V2-ENCODED',
      ),
      throwsStateError,
    );

    expect(decryptCalled, isFalse);
  });

  test('fails closed before authorization for empty encoded payload', () async {
    bool authorizeCalled = false;

    final CamoVerifiedV2WorkspaceDecodeCoordinator coordinator =
        CamoVerifiedV2WorkspaceDecodeCoordinator(
          authorize:
              ({
                required Map<String, Object?> payload,
                required String expectedRequestId,
              }) async {
                authorizeCalled = true;
                throw StateError('must not run');
              },
          decrypt:
              ({
                required String requestId,
                required String operationId,
                required String messageId,
                required String pairingId,
                required String encodedText,
              }) async => 'must-not-run',
        );

    await expectLater(
      coordinator.decode(
        requestId: 'request-1',
        authorization: _authorization(),
        encodedText: '   ',
      ),
      throwsStateError,
    );

    expect(authorizeCalled, isFalse);
  });
}

CamoEnterpriseAuthorizationRequest _authorization() {
  return CamoEnterpriseAuthorizationRequest(
    operationId: 'operation-1',
    userId: 'user-1',
    deviceId: 'device-1',
    operationType: CamoOperationType.decode,
    keyPurpose: CamoKeyPurpose.messageDecryption,
    keyScope: CamoKeyScope.message,
    requestedAt: DateTime.utc(2026, 7, 23, 10),
    requiredEntitlements: const <CamoEntitlementType>{
      CamoEntitlementType.baseDecoding,
    },
    pairId: 'pair-1',
    messageId: 'message-1',
    attributes: const <String, String>{'source': 'workspace'},
  );
}

CamoSignedAuthorizationContractV2 _contract({
  required String requestId,
  required String operationId,
  required String userId,
  required String deviceId,
  required String pairId,
  required String messageId,
  required String payloadDigest,
}) {
  return CamoSignedAuthorizationContractV2(
    schemaVersion: 2,
    canonicalizationVersion: 'CAMO_AUTHORIZATION_V2',
    requestId: requestId,
    authorized: true,
    authorizationId: 'authorization-1',
    operationId: operationId,
    challengeId: 'challenge-1',
    userId: userId,
    deviceId: deviceId,
    pairId: pairId,
    messageId: messageId,
    payloadDigest: payloadDigest,
    keyReleaseId: 'key-release-1',
    keyReference: 'key-reference-1',
    sessionId: 'session-1',
    serverShareId: 'share-1',
    serverShareVersion: 1,
    serverShareBase64: 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=',
    serverShareExpiresAt: DateTime.utc(2026, 7, 23, 10, 5),
    issuedAt: DateTime.utc(2026, 7, 23, 10),
    expiresAt: DateTime.utc(2026, 7, 23, 10, 5),
    reasonCode: 'server_authorization_granted',
    signatureAlgorithm: 'EC_SIGN_P256_SHA256',
    signatureEncoding: 'DER_BASE64',
    signingKeyId: 'signing-key-1',
    signature: 'AQ==',
  );
}
