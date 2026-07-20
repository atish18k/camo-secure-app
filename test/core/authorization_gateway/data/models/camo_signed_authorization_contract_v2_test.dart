import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> createValidV2Payload() {
  return <String, Object?>{
    'schemaVersion': 2,
    'canonicalizationVersion': 'CAMO_AUTHORIZATION_V2',
    'requestId': 'request-001',
    'authorized': true,
    'authorizationId': 'authorization-001',
    'operationId': 'operation-001',
    'challengeId': 'challenge-001',
    'userId': 'user-001',
    'deviceId': 'device-001',
    'pairId': 'pair-001',
    'messageId': 'message-001',
    'payloadDigest': 'a' * 64,
    'keyReleaseId': 'release-001',
    'keyReference': 'key-reference-001',
    'sessionId': 'session-001',
    'serverShareId': 'share-001',
    'serverShareVersion': 1,
    'serverShareBase64': 'BwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwc=',
    'serverShareExpiresAt': '2026-07-21T00:01:00.000Z',
    'issuedAt': '2026-07-21T00:00:00.000Z',
    'expiresAt': '2026-07-21T00:01:00.000Z',
    'reasonCode': 'server_authorization_granted',
    'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
    'signatureEncoding': 'DER_BASE64',
    'signingKeyId': 'signing-key-001',
    'signature': 'MEUCIQDbase64',
  };
}

void main() {
  test('accepts exact repository-aligned V2 signed grant', () {
    final CamoSignedAuthorizationContractV2 contract =
        CamoSignedAuthorizationContractV2.fromPayload(createValidV2Payload());

    expect(contract.authorized, isTrue);
    expect(contract.serverShareVersion, 1);
    expect(contract.decodeServerShareBytes(), hasLength(32));
  });

  test('rejects unknown fields fail closed', () {
    final Map<String, Object?> payload = createValidV2Payload()
      ..['unexpected'] = 'forbidden';

    expect(
      () => CamoSignedAuthorizationContractV2.fromPayload(payload),
      throwsFormatException,
    );
  });

  test('rejects denied response as signed V2 grant', () {
    final Map<String, Object?> payload = createValidV2Payload()
      ..['authorized'] = false;

    expect(
      () => CamoSignedAuthorizationContractV2.fromPayload(payload),
      throwsFormatException,
    );
  });

  test('rejects invalid ServerShare byte length', () {
    final Map<String, Object?> payload = createValidV2Payload()
      ..['serverShareBase64'] = 'AQI=';

    expect(
      () => CamoSignedAuthorizationContractV2.fromPayload(payload),
      throwsFormatException,
    );
  });

  test('rejects ServerShare expiry beyond permit expiry', () {
    final Map<String, Object?> payload = createValidV2Payload()
      ..['serverShareExpiresAt'] = '2026-07-21T00:02:00.000Z';

    expect(
      () => CamoSignedAuthorizationContractV2.fromPayload(payload),
      throwsFormatException,
    );
  });
}
