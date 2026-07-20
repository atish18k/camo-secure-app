import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_transport_result.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_transport_dispatcher.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v1_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v2_transport_decoder.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_versioned_authorization_callable_client.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_callable_primitive.dart';
import 'package:flutter_test/flutter_test.dart';

const String requestIdV1 = 'request-v1';
const String requestIdV2 = 'request-v2';

Map<String, Object?> validV1Payload() {
  return <String, Object?>{
    'schemaVersion': 1,
    'canonicalizationVersion': 'CAMO_AUTHORIZATION_V1',
    'requestId': requestIdV1,
    'authorized': true,
    'authorizationId': 'authorization-v1',
    'operationId': 'operation-v1',
    'challengeId': 'challenge-v1',
    'userId': 'user-v1',
    'deviceId': 'device-v1',
    'keyReleaseId': 'release-v1',
    'keyReference': 'key-reference-v1',
    'sessionId': 'session-v1',
    'issuedAt': '2026-07-21T00:00:00.000Z',
    'expiresAt': '2026-07-21T00:01:00.000Z',
    'reasonCode': 'server_authorization_granted',
    'signature': 'AQ==',
    'signingKeyId': 'signing-key-v1',
    'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
    'signatureEncoding': 'DER_BASE64',
  };
}

Map<String, Object?> validV2Payload() {
  return <String, Object?>{
    'schemaVersion': 2,
    'canonicalizationVersion': 'CAMO_AUTHORIZATION_V2',
    'requestId': requestIdV2,
    'authorized': true,
    'authorizationId': 'authorization-v2',
    'operationId': 'operation-v2',
    'challengeId': 'challenge-v2',
    'userId': 'user-v2',
    'deviceId': 'device-v2',
    'pairId': 'pair-v2',
    'messageId': 'message-v2',
    'payloadDigest': 'b' * 64,
    'keyReleaseId': 'release-v2',
    'keyReference': 'key-reference-v2',
    'sessionId': 'session-v2',
    'serverShareId': 'share-v2',
    'serverShareVersion': 1,
    'serverShareBase64': 'BwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwc=',
    'serverShareExpiresAt': '2026-07-21T00:01:00.000Z',
    'issuedAt': '2026-07-21T00:00:00.000Z',
    'expiresAt': '2026-07-21T00:01:00.000Z',
    'reasonCode': 'server_authorization_granted',
    'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
    'signatureEncoding': 'DER_BASE64',
    'signingKeyId': 'signing-key-v2',
    'signature': 'AQ==',
  };
}

CamoSignedAuthorizationContractTransportDispatcher verifiedDispatcher() {
  return CamoSignedAuthorizationContractTransportDispatcher(
    v1Decoder: CamoSignedAuthorizationContractV1TransportDecoder(
      verifyContract: (_) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    ),
    v2Decoder: CamoSignedAuthorizationContractV2TransportDecoder(
      verifyContract: (_) async {
        return const CamoAuthorizationSignatureVerificationDecision.verified();
      },
    ),
  );
}

void main() {
  test('verified V1 callable response is released as V1 result', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      response: validV1Payload(),
    );

    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: primitive,
          dispatcher: verifiedDispatcher(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestIdV1},
      expectedRequestId: requestIdV1,
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, isA<CamoSignedAuthorizationTransportResultV1>());
    expect(result.valueOrNull?.schemaVersion, 1);
    expect(primitive.callCount, 1);
  });

  test('verified V2 callable response is released as V2 result', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      response: validV2Payload(),
    );

    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: primitive,
          dispatcher: verifiedDispatcher(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestIdV2},
      expectedRequestId: requestIdV2,
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, isA<CamoSignedAuthorizationTransportResultV2>());
    expect(result.valueOrNull?.schemaVersion, 2);
    expect(primitive.callCount, 1);
  });

  test('request mismatch is denied before callable invocation', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      response: validV2Payload(),
    );

    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: primitive,
          dispatcher: verifiedDispatcher(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': 'different-request'},
      expectedRequestId: requestIdV2,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'versioned_authorization_callable_request_invalid',
    );
    expect(primitive.callCount, 0);
  });

  test('callable exception becomes sanitized network failure', () async {
    final _FakeCallablePrimitive primitive = _FakeCallablePrimitive(
      error: StateError('sensitive simulated backend detail'),
    );

    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: primitive,
          dispatcher: verifiedDispatcher(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestIdV2},
      expectedRequestId: requestIdV2,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'versioned_authorization_callable_unavailable',
    );
    expect(result.failureOrNull?.cause, isNull);
    expect(
      result.failureOrNull?.message,
      isNot(contains('sensitive simulated backend detail')),
    );
  });

  test('non-map callable response fails closed', () async {
    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: _FakeCallablePrimitive(response: 'invalid'),
          dispatcher: verifiedDispatcher(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestIdV2},
      expectedRequestId: requestIdV2,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'versioned_authorization_callable_response_invalid',
    );
  });

  test('unsupported response version fails closed', () async {
    final Map<String, Object?> response = validV2Payload()
      ..['schemaVersion'] = 99;

    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: _FakeCallablePrimitive(response: response),
          dispatcher: verifiedDispatcher(),
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestIdV2},
      expectedRequestId: requestIdV2,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'versioned_authorization_callable_response_rejected',
    );
  });

  test('cryptographically denied V2 response fails closed', () async {
    final CamoSignedAuthorizationContractTransportDispatcher
    dispatcher = CamoSignedAuthorizationContractTransportDispatcher(
      v1Decoder: CamoSignedAuthorizationContractV1TransportDecoder(
        verifyContract: (_) async {
          return const CamoAuthorizationSignatureVerificationDecision.verified();
        },
      ),
      v2Decoder: CamoSignedAuthorizationContractV2TransportDecoder(
        verifyContract: (_) async {
          return const CamoAuthorizationSignatureVerificationDecision.denied(
            'authorization_v2_signature_invalid',
          );
        },
      ),
    );

    final CamoVersionedAuthorizationCallableClient client =
        CamoVersionedAuthorizationCallableClient(
          primitive: _FakeCallablePrimitive(response: validV2Payload()),
          dispatcher: dispatcher,
        );

    final result = await client.authorize(
      payload: <String, Object?>{'requestId': requestIdV2},
      expectedRequestId: requestIdV2,
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'versioned_authorization_callable_response_rejected',
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
