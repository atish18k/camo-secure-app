import 'dart:convert';

import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v2_canonicalizer.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> createCanonicalizerPayload() {
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
  test('client V2 canonical order matches frozen server order', () {
    final CamoSignedAuthorizationContractV2 contract =
        CamoSignedAuthorizationContractV2.fromPayload(
          createCanonicalizerPayload(),
        );

    final String canonical =
        const CamoSignedAuthorizationContractV2Canonicalizer().canonicalize(
          contract,
        );

    final List<String> fields = LineSplitter.split(
      canonical,
    ).map((String line) => line.substring(0, line.indexOf('='))).toList();

    expect(fields, <String>[
      'schemaVersion',
      'canonicalizationVersion',
      'requestId',
      'authorized',
      'authorizationId',
      'operationId',
      'challengeId',
      'userId',
      'deviceId',
      'pairId',
      'messageId',
      'payloadDigest',
      'keyReleaseId',
      'keyReference',
      'sessionId',
      'serverShareId',
      'serverShareVersion',
      'serverShareBase64',
      'serverShareExpiresAt',
      'issuedAt',
      'expiresAt',
      'reasonCode',
    ]);
  });
}
