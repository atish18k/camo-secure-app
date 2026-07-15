import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v1.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v1_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String requestId = 'step-29b-request-001';

  Map<Object?, Object?> validPayload() {
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
      'keyReleaseId': 'release-001',
      'keyReference': 'kms-key-reference-001',
      'sessionId': 'session-001',
      'issuedAt': '2026-07-15T00:00:00.000Z',
      'expiresAt': '2026-07-15T00:02:00.000Z',
      'reasonCode': 'server_authorization_granted',
      'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
      'signatureEncoding': 'DER_BASE64',
      'signingKeyId':
          'camo-b3cab:asia-south1:camo-prod-authz-kr:'
          'camo-operation-signing:1',
      'signature': 'AQID',
    };
  }

  test('verified Version-1 response is released to the caller', () async {
    final CamoSignedAuthorizationContractV1TransportDecoder
    decoder = CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (contract) async {
        expect(contract.requestId, requestId);

        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    final CamoSignedAuthorizationContractV1 contract = await decoder
        .decodeAndVerify(payload: validPayload(), expectedRequestId: requestId);

    expect(contract.requestId, requestId);
    expect(contract.authorized, isTrue);
  });

  test('request identifier mismatch fails before verification', () async {
    bool verifierCalled = false;

    final CamoSignedAuthorizationContractV1TransportDecoder
    decoder = CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (contract) async {
        verifierCalled = true;

        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    await expectLater(
      decoder.decodeAndVerify(
        payload: validPayload(),
        expectedRequestId: 'different-request-id',
      ),
      throwsA(isA<StateError>()),
    );

    expect(verifierCalled, isFalse);
  });

  test('unknown response field fails closed', () async {
    final Map<Object?, Object?> payload = validPayload()
      ..['unexpectedField'] = 'must-be-rejected';

    final CamoSignedAuthorizationContractV1TransportDecoder
    decoder = CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (contract) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    await expectLater(
      decoder.decodeAndVerify(payload: payload, expectedRequestId: requestId),
      throwsA(isA<StateError>()),
    );
  });

  test('legacy gateway response shape fails closed', () async {
    final CamoSignedAuthorizationContractV1TransportDecoder
    decoder = CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (contract) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    await expectLater(
      decoder.decodeAndVerify(
        payload: <Object?, Object?>{
          'responseId': 'legacy-response',
          'requestId': requestId,
          'pipelineDecision': <Object?, Object?>{},
          'serverTime': '2026-07-15T00:00:00.000Z',
          'signature': 'AQID',
        },
        expectedRequestId: requestId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('cryptographic denial fails closed', () async {
    final CamoSignedAuthorizationContractV1TransportDecoder decoder =
        CamoSignedAuthorizationContractV1TransportDecoder(
          verifyContract: (contract) async {
            return const CamoAuthorizationSignatureVerificationDecision.denied(
              'authorization_signature_invalid',
            );
          },
        );

    await expectLater(
      decoder.decodeAndVerify(
        payload: validPayload(),
        expectedRequestId: requestId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('verifier exception fails closed', () async {
    final CamoSignedAuthorizationContractV1TransportDecoder decoder =
        CamoSignedAuthorizationContractV1TransportDecoder(
          verifyContract: (contract) async {
            throw StateError('simulated verifier failure');
          },
        );

    await expectLater(
      decoder.decodeAndVerify(
        payload: validPayload(),
        expectedRequestId: requestId,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('empty expected request identifier fails closed', () async {
    bool verifierCalled = false;

    final CamoSignedAuthorizationContractV1TransportDecoder
    decoder = CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (contract) async {
        verifierCalled = true;

        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );

    await expectLater(
      decoder.decodeAndVerify(payload: validPayload(), expectedRequestId: ''),
      throwsA(isA<StateError>()),
    );

    expect(verifierCalled, isFalse);
  });
}
