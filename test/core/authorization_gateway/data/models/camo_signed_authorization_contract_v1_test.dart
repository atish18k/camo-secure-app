import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v1.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<Object?, Object?> createValidPayload() {
    return <Object?, Object?>{
      'schemaVersion': 1,
      'canonicalizationVersion': 'CAMO_AUTHORIZATION_V1',
      'requestId': 'request-001',
      'authorized': true,
      'authorizationId': 'authorization-001',
      'operationId': 'operation-001',
      'challengeId': 'challenge-001',
      'userId': 'user-001',
      'deviceId': 'device-001',
      'pairId': 'pair-001',
      'messageId': null,
      'keyReleaseId': 'release-001',
      'keyReference': 'kms-key-version-001',
      'sessionId': 'session-001',
      'issuedAt': '2026-07-14T12:00:00.000Z',
      'expiresAt': '2026-07-14T12:01:00.000Z',
      'reasonCode': 'server_authorization_granted',
      'signature': 'MEUCIQABAgM=',
      'signingKeyId': 'camo-operation-signing',
      'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
      'signatureEncoding': 'DER_BASE64',
    };
  }

  test('parses exact signed authorization contract V1', () {
    final CamoSignedAuthorizationContractV1 contract =
        CamoSignedAuthorizationContractV1.parse(createValidPayload());

    expect(contract.schemaVersion, 1);
    expect(contract.requestId, 'request-001');
    expect(contract.authorizationId, 'authorization-001');
    expect(contract.signatureAlgorithm, 'EC_SIGN_P256_SHA256');
    expect(contract.signatureEncoding, 'DER_BASE64');
    expect(contract.isWithinValidityWindow, isTrue);
    expect(contract.decodeDerSignature(), isNotEmpty);
  });

  test('rejects missing request binding', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..remove('requestId');

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });

  test('rejects unsupported schema version', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..['schemaVersion'] = 2;

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });

  test('rejects unsupported signature algorithm', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..['signatureAlgorithm'] = 'UNAPPROVED_ALGORITHM';

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });

  test('rejects unknown response fields', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..['unexpectedField'] = 'unexpected-value';

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });

  test('rejects invalid authorization validity window', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..['expiresAt'] = '2026-07-14T11:59:59.000Z';

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });

  test('rejects a denied response as a signed grant', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..['authorized'] = false;

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });

  test('rejects malformed Base64 signature encoding', () {
    final Map<Object?, Object?> payload = createValidPayload()
      ..['signature'] = 'not-valid-base64!';

    expect(
      () => CamoSignedAuthorizationContractV1.parse(payload),
      throwsFormatException,
    );
  });
}
