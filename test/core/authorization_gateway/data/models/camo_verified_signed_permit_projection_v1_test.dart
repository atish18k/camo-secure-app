import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v1.dart';
import 'package:camo/core/authorization_gateway/data/models/camo_verified_signed_permit_projection_v1.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects the already parsed signed authorization grant', () {
    final CamoSignedAuthorizationContractV1 contract =
        CamoSignedAuthorizationContractV1.parse(<Object?, Object?>{
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
          'messageId': 'message-001',
          'keyReleaseId': 'release-001',
          'keyReference': 'key-001',
          'sessionId': 'session-001',
          'issuedAt': '2026-07-20T12:00:00.000Z',
          'expiresAt': '2026-07-20T12:01:00.000Z',
          'reasonCode': 'authorized',
          'signature': 'MAYCAQE=',
          'signingKeyId': 'key-version-001',
          'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
          'signatureEncoding': 'DER_BASE64',
        });

    final CamoVerifiedSignedPermitProjectionV1 projection =
        CamoVerifiedSignedPermitProjectionV1.fromVerifiedContract(contract);

    expect(projection.isStructurallyValid, isTrue);
    expect(projection.authorizationId, 'authorization-001');
    expect(projection.keyReleaseId, 'release-001');
    expect(projection.keyReference, 'key-001');
    expect(projection.sessionId, 'session-001');
  });
}
