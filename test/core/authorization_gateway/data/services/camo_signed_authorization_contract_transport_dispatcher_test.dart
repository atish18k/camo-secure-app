import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_transport_result.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_transport_dispatcher.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v1_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v2_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:flutter_test/flutter_test.dart';

Map<Object?, Object?> validV1Payload() {
  return <Object?, Object?>{
    'schemaVersion': 1,
    'canonicalizationVersion': 'CAMO_AUTHORIZATION_V1',
    'requestId': 'request-v1',
    'authorized': true,
    'authorizationId': 'authorization-v1',
    'operationId': 'operation-v1',
    'challengeId': 'challenge-v1',
    'userId': 'user-v1',
    'deviceId': 'device-v1',
    'keyReleaseId': 'release-v1',
    'keyReference': 'key-reference-v1',
    'sessionId': 'session-v1',
    'issuedAt': '2026-07-21T00:00:00.000Z',
    'expiresAt': '2026-07-21T00:01:00.000Z',
    'reasonCode': 'server_authorization_granted',
    'signature': 'AQ==',
    'signingKeyId': 'signing-key-v1',
    'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
    'signatureEncoding': 'DER_BASE64',
  };
}

Map<Object?, Object?> validV2Payload() {
  return <Object?, Object?>{
    'schemaVersion': 2,
    'canonicalizationVersion': 'CAMO_AUTHORIZATION_V2',
    'requestId': 'request-v2',
    'authorized': true,
    'authorizationId': 'authorization-v2',
    'operationId': 'operation-v2',
    'challengeId': 'challenge-v2',
    'userId': 'user-v2',
    'deviceId': 'device-v2',
    'pairId': 'pair-v2',
    'messageId': 'message-v2',
    'payloadDigest': 'b' * 64,
    'keyReleaseId': 'release-v2',
    'keyReference': 'key-reference-v2',
    'sessionId': 'session-v2',
    'serverShareId': 'share-v2',
    'serverShareVersion': 1,
    'serverShareBase64': 'BwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwc=',
    'serverShareExpiresAt': '2026-07-21T00:01:00.000Z',
    'issuedAt': '2026-07-21T00:00:00.000Z',
    'expiresAt': '2026-07-21T00:01:00.000Z',
    'reasonCode': 'server_authorization_granted',
    'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
    'signatureEncoding': 'DER_BASE64',
    'signingKeyId': 'signing-key-v2',
    'signature': 'AQ==',
  };
}

CamoSignedAuthorizationContractTransportDispatcher dispatcher() {
  return CamoSignedAuthorizationContractTransportDispatcher(
    v1Decoder: CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (_) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    ),
    v2Decoder: CamoSignedAuthorizationContractV2TransportDecoder(
      verifyContract: (_) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    ),
  );
}

void main() {
  test('dispatcher routes exact V1 contract', () async {
    final result = await dispatcher().decodeAndVerify(
      payload: validV1Payload(),
      expectedRequestId: 'request-v1',
    );

    expect(result, isA<CamoSignedAuthorizationTransportResultV1>());
    expect(result.schemaVersion, 1);
  });

  test('dispatcher routes exact V2 contract', () async {
    final result = await dispatcher().decodeAndVerify(
      payload: validV2Payload(),
      expectedRequestId: 'request-v2',
    );

    expect(result, isA<CamoSignedAuthorizationTransportResultV2>());
    expect(result.schemaVersion, 2);
  });

  test('dispatcher rejects unsupported version fail closed', () async {
    final Map<Object?, Object?> payload = validV2Payload()
      ..['schemaVersion'] = 3;

    expect(
      dispatcher().decodeAndVerify(
        payload: payload,
        expectedRequestId: 'request-v2',
      ),
      throwsStateError,
    );
  });

  test(
    'dispatcher rejects mixed schema and canonicalization versions',
    () async {
      final Map<Object?, Object?> payload = validV2Payload()
        ..['canonicalizationVersion'] = 'CAMO_AUTHORIZATION_V1';

      expect(
        dispatcher().decodeAndVerify(
          payload: payload,
          expectedRequestId: 'request-v2',
        ),
        throwsStateError,
      );
    },
  );
}
