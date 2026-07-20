import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:camo/core/authorization_gateway/data/models/camo_verified_signed_permit_projection_v2.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> createProjectionPayload() {
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
  test('verified projection creates existing operation-bound ServerShare', () {
    final CamoSignedAuthorizationContractV2 contract =
        CamoSignedAuthorizationContractV2.fromPayload(
          createProjectionPayload(),
        );

    final CamoVerifiedSignedPermitProjectionV2 projection =
        CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(contract);

    expect(projection.authorizationId, 'authorization-001');
    expect(projection.operationId, 'operation-001');
    expect(projection.serverShare.shareId, 'share-001');
    expect(projection.serverShare.operationId, 'operation-001');
    expect(projection.serverShare.version, 1);
    expect(projection.serverShare.bytes, hasLength(32));
  });
}
