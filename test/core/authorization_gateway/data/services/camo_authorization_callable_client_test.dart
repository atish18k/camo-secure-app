import 'package:camo/core/authorization_gateway/data/services/camo_authorization_callable_client.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v1_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_callable_primitive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String requestId = 'step-30b-request-001';

  Map<String, Object?> validPayload() {
    return <String, Object?>{
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

  CamoSignedAuthorizationContractV1TransportDecoder verifiedDecoder() {
    return CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (contract) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    );
  }

  test('verified callable response is released', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      response: validPayload(),
    );

    final CamoAuthorizationCallableClient client =
        CamoAuthorizationCallableClient(
          primitive: primitive,
          decoder: verifiedDecoder(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{
        'requestId': requestId,
        'operationId': 'operation-001',
      },
      expectedRequestId: requestId,
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.requestId, requestId);
    expect(primitive.callCount, 1);
  });

  test('request mismatch is denied before network invocation', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      response: validPayload(),
    );

    final CamoAuthorizationCallableClient client =
        CamoAuthorizationCallableClient(
          primitive: primitive,
          decoder: verifiedDecoder(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': 'different-request'},
      expectedRequestId: requestId,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'authorization_callable_request_invalid',
    );
    expect(primitive.callCount, 0);
  });

  test('callable exception becomes sanitized network failure', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      error: StateError('sensitive simulated backend detail'),
    );

    final CamoAuthorizationCallableClient client =
        CamoAuthorizationCallableClient(
          primitive: primitive,
          decoder: verifiedDecoder(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestId},
      expectedRequestId: requestId,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, 'authorization_callable_unavailable');
    expect(result.failureOrNull?.cause, isNull);
    expect(
      result.failureOrNull?.message,
      isNot(contains('sensitive simulated backend detail')),
    );
  });

  test('non-map callable response fails closed', () async {
    final CamoAuthorizationCallableClient client =
        CamoAuthorizationCallableClient(
          primitive: _FakeCallablePrimitive(response: 'invalid'),
          decoder: verifiedDecoder(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestId},
      expectedRequestId: requestId,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'authorization_callable_response_invalid',
    );
  });

  test('cryptographically rejected response fails closed', () async {
    final CamoSignedAuthorizationContractV1TransportDecoder decoder =
        CamoSignedAuthorizationContractV1TransportDecoder(
          verifyContract: (contract) async {
            return const CamoAuthorizationSignatureVerificationDecision.denied(
              'authorization_signature_invalid',
            );
          },
        );

    final CamoAuthorizationCallableClient client =
        CamoAuthorizationCallableClient(
          primitive: _FakeCallablePrimitive(response: validPayload()),
          decoder: decoder,
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestId},
      expectedRequestId: requestId,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'authorization_callable_response_rejected',
    );
  });
}

final class _FakeCallablePrimitive
    implements CamoAuthorizationCallablePrimitive {
  _FakeCallablePrimitive({this.response, this.error});

  final Object? response;
  final Object? error;
  int callCount = 0;

  @override
  Future<Object?> call(Map<String, Object?> payload) async {
    callCount++;

    if (error != null) {
      throw error!;
    }

    return response;
  }
}
