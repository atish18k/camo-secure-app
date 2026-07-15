import 'dart:convert';

import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v1.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v1_canonicalizer.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String expectedCanonicalPayload = <String>[
    'schemaVersion=1',
    'canonicalizationVersion=CAMO_AUTHORIZATION_V1',
    'requestId=request-001',
    'authorized=true',
    'authorizationId=authorization-001',
    'operationId=operation-001',
    'challengeId=challenge-001',
    'userId=user-001',
    'deviceId=device-001',
    'pairId=pair-001',
    'messageId=',
    'keyReleaseId=release-001',
    'keyReference=key-001',
    'sessionId=session-001',
    'issuedAt=2026-07-13T12:00:00.000Z',
    'expiresAt=2026-07-13T12:01:00.000Z',
    'reasonCode=server_authorization_granted',
  ].join('\n');

  const String expectedSha256 =
      '44a93a222988e68fb1667675c7e266b8a'
      '7fd0c3b16f2b8a1129247b2be634587';

  Map<Object?, Object?> createPayload({String requestId = 'request-001'}) {
    return <Object?, Object?>{
      'schemaVersion': 1,
      'canonicalizationVersion': 'CAMO_AUTHORIZATION_V1',
      'requestId': requestId,
      'authorized': true,
      'authorizationId': 'authorization-001',
      'operationId': 'operation-001',
      'challengeId': 'challenge-001',
      'userId': 'user-001',
      'deviceId': 'device-001',
      'pairId': 'pair-001',
      'messageId': null,
      'keyReleaseId': 'release-001',
      'keyReference': 'key-001',
      'sessionId': 'session-001',
      'issuedAt': '2026-07-13T12:00:00.000Z',
      'expiresAt': '2026-07-13T12:01:00.000Z',
      'reasonCode': 'server_authorization_granted',
      'signature': 'MEUCIQABAgM=',
      'signingKeyId': 'camo-operation-signing',
      'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
      'signatureEncoding': 'DER_BASE64',
    };
  }

  test('client canonical payload matches server Version-1 bytes', () {
    final CamoSignedAuthorizationContractV1 contract =
        CamoSignedAuthorizationContractV1.parse(createPayload());

    const CamoSignedAuthorizationContractV1Canonicalizer canonicalizer =
        CamoSignedAuthorizationContractV1Canonicalizer();

    final String canonical = canonicalizer.canonicalize(contract);

    expect(utf8.encode(canonical), utf8.encode(expectedCanonicalPayload));
  });

  test('client canonical payload matches locked SHA-256 fingerprint', () async {
    final CamoSignedAuthorizationContractV1 contract =
        CamoSignedAuthorizationContractV1.parse(createPayload());

    const CamoSignedAuthorizationContractV1Canonicalizer canonicalizer =
        CamoSignedAuthorizationContractV1Canonicalizer();

    final String canonical = canonicalizer.canonicalize(contract);
    final Hash digest = await Sha256().hash(utf8.encode(canonical));

    final String hex = digest.bytes
        .map((int value) => value.toRadixString(16).padLeft(2, '0'))
        .join();

    expect(hex, expectedSha256);
  });

  test('canonicalizer rejects line-break field injection', () {
    final CamoSignedAuthorizationContractV1 contract =
        CamoSignedAuthorizationContractV1.parse(
          createPayload(requestId: 'request-001\noperationId=attacker'),
        );

    const CamoSignedAuthorizationContractV1Canonicalizer canonicalizer =
        CamoSignedAuthorizationContractV1Canonicalizer();

    expect(() => canonicalizer.canonicalize(contract), throwsFormatException);
  });
}
