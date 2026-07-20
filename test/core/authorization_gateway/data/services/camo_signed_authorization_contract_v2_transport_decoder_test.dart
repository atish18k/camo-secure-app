import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v2_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:flutter_test/flutter_test.dart';

Map<Object?, Object?> validV2Payload() {
  return <Object?, Object?>{
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
  test('V2 decoder accepts verified request-bound contract', () async {
    final CamoSignedAuthorizationContractV2TransportDecoder
    decoder = CamoSignedAuthorizationContractV2TransportDecoder(
      verifyContract: (_) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    final contract = await decoder.decodeAndVerify(
      payload: validV2Payload(),
      expectedRequestId: 'request-001',
    );

    expect(contract.schemaVersion, 2);
    expect(contract.serverShareId, 'share-001');
  });

  test('V2 decoder rejects request binding mismatch', () async {
    final CamoSignedAuthorizationContractV2TransportDecoder
    decoder = CamoSignedAuthorizationContractV2TransportDecoder(
      verifyContract: (_) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    expect(
      decoder.decodeAndVerify(
        payload: validV2Payload(),
        expectedRequestId: 'other-request',
      ),
      throwsStateError,
    );
  });

  test('V2 decoder rejects denied signature decision', () async {
    final CamoSignedAuthorizationContractV2TransportDecoder decoder =
        CamoSignedAuthorizationContractV2TransportDecoder(
          verifyContract: (_) async {
            return const CamoAuthorizationSignatureVerificationDecision.denied(
              'test_denial',
            );
          },
        );

    expect(
      decoder.decodeAndVerify(
        payload: validV2Payload(),
        expectedRequestId: 'request-001',
      ),
      throwsStateError,
    );
  });
}
