import 'dart:io';

import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:camo/core/authorization_gateway/data/models/camo_verified_signed_permit_projection_v2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verified projection preserves exact signed V2 bridge fields', () {
    final CamoVerifiedSignedPermitProjectionV2 permit =
        CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(_contract());

    expect(permit.requestId, 'request-1');
    expect(permit.authorizationId, 'authorization-1');
    expect(permit.operationId, 'operation-1');
    expect(permit.challengeId, 'challenge-1');
    expect(permit.userId, 'user-1');
    expect(permit.deviceId, 'device-1');
    expect(permit.pairId, 'pair-1');
    expect(permit.messageId, 'message-1');
    expect(permit.sessionId, 'session-1');
    expect(permit.keyReleaseId, 'key-release-1');
    expect(permit.keyReference, 'key-reference-1');
    expect(permit.signingKeyId, 'signing-key-1');
    expect(permit.signature, 'AQ==');
    expect(permit.isValid, isTrue);
  });

  test('projection keeps ServerShare bound to the same operation', () {
    final CamoVerifiedSignedPermitProjectionV2 permit =
        CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(_contract());

    expect(permit.serverShare.operationId, permit.operationId);
    expect(permit.serverShare.bytes, hasLength(32));
  });

  test('projection does not invent downstream decision entities', () {
    const String sourcePath =
        'lib/core/authorization_gateway/data/models/'
        'camo_verified_signed_permit_projection_v2.dart';

    final String source = File(sourcePath).readAsStringSync();

    expect(source, isNot(contains('CamoRiskDecision')));
    expect(source, isNot(contains('CamoPolicyDecision')));
    expect(source, isNot(contains('CamoCommercialAccessDecision')));
  });
}

CamoSignedAuthorizationContractV2 _contract() {
  return CamoSignedAuthorizationContractV2(
    schemaVersion: 2,
    canonicalizationVersion: 'CAMO_AUTHORIZATION_V2',
    requestId: 'request-1',
    authorized: true,
    authorizationId: 'authorization-1',
    operationId: 'operation-1',
    challengeId: 'challenge-1',
    userId: 'user-1',
    deviceId: 'device-1',
    pairId: 'pair-1',
    messageId: 'message-1',
    payloadDigest: 'payload-digest-1',
    keyReleaseId: 'key-release-1',
    keyReference: 'key-reference-1',
    sessionId: 'session-1',
    serverShareId: 'share-1',
    serverShareVersion: 1,
    serverShareBase64: 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=',
    serverShareExpiresAt: DateTime.utc(2026, 7, 23, 10, 5),
    issuedAt: DateTime.utc(2026, 7, 23, 10),
    expiresAt: DateTime.utc(2026, 7, 23, 10, 5),
    reasonCode: 'authorized',
    signatureAlgorithm: 'EC_SIGN_P256_SHA256',
    signatureEncoding: 'DER_BASE64',
    signingKeyId: 'signing-key-1',
    signature: 'AQ==',
  );
}
