import 'dart:convert';

import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v1.dart';
import 'package:camo/core/authorization_gateway/data/security/camo_p256_der_signature_decoder.dart';
import 'package:camo/core/authorization_gateway/data/security/camo_p256_signature_verification_primitive.dart';
import 'package:camo/core/authorization_gateway/data/security/camo_pinned_authorization_public_key_v1.dart';
import 'package:camo/core/authorization_gateway/data/security/camo_signed_authorization_contract_v1_verifier.dart';
import 'package:camo/core/authorization_gateway/data/security/cryptography_camo_p256_signature_verification_primitive.dart';
import 'package:camo/core/authorization_gateway/data/services/camo_signed_authorization_contract_v1_canonicalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedNow = DateTime.utc(2026, 7, 15, 0, 0, 30);

  List<int> createDerSignature() {
    final List<int> r = <int>[0x01, ...List<int>.filled(31, 0x11)];
    final List<int> s = <int>[0x02, ...List<int>.filled(31, 0x22)];

    return <int>[0x30, 0x44, 0x02, 0x20, ...r, 0x02, 0x20, ...s];
  }

  CamoSignedAuthorizationContractV1 createContract({
    String? signingKeyId,
    String? signature,
    DateTime? issuedAt,
    DateTime? expiresAt,
  }) {
    return CamoSignedAuthorizationContractV1.parse(<Object?, Object?>{
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
      'keyReference': 'key-001',
      'sessionId': 'session-001',
      'issuedAt': (issuedAt ?? DateTime.utc(2026, 7, 15)).toIso8601String(),
      'expiresAt': (expiresAt ?? DateTime.utc(2026, 7, 15, 0, 1))
          .toIso8601String(),
      'reasonCode': 'server_authorization_granted',
      'signature': signature ?? base64Encode(createDerSignature()),
      'signingKeyId':
          signingKeyId ?? CamoPinnedAuthorizationPublicKeyV1.signingKeyId,
      'signatureAlgorithm': 'EC_SIGN_P256_SHA256',
      'signatureEncoding': 'DER_BASE64',
    });
  }

  CamoSignedAuthorizationContractV1Verifier createVerifier(
    _FakePrimitive primitive,
  ) {
    return CamoSignedAuthorizationContractV1Verifier(
      canonicalizer: const CamoSignedAuthorizationContractV1Canonicalizer(),
      derDecoder: const CamoP256DerSignatureDecoder(),
      pinnedKey: const CamoPinnedAuthorizationPublicKeyV1(),
      primitive: primitive,
      clock: () => fixedNow,
    );
  }

  test('production cryptography adapter implements primitive contract', () {
    final CryptographyCamoP256SignatureVerificationPrimitive adapter =
        CryptographyCamoP256SignatureVerificationPrimitive();

    expect(adapter, isA<CamoP256SignatureVerificationPrimitive>());
  });

  test('verified primitive permits exact signed contract', () async {
    final _FakePrimitive primitive = _FakePrimitive(result: true);
    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(createContract());

    expect(decision.permitsResponseUse, isTrue);
    expect(primitive.callCount, 1);
    expect(primitive.lastMessage, isNotEmpty);
    expect(primitive.lastRawSignature, hasLength(64));
    expect(primitive.lastPublicKeyX, hasLength(32));
    expect(primitive.lastPublicKeyY, hasLength(32));

    expect(
      utf8.decode(primitive.lastMessage),
      contains('requestId=request-001'),
    );
  });

  test('unrecognized signing key fails closed before primitive', () async {
    final _FakePrimitive primitive = _FakePrimitive(result: true);
    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(
      createContract(signingKeyId: 'unapproved-key-version'),
    );

    expect(decision.permitsResponseUse, isFalse);
    expect(decision.reasonCode, 'authorization_signing_key_not_pinned');
    expect(primitive.callCount, 0);
  });

  test('expired authorization fails closed before primitive', () async {
    final _FakePrimitive primitive = _FakePrimitive(result: true);
    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(
      createContract(
        issuedAt: DateTime.utc(2026, 7, 14, 23, 58),
        expiresAt: DateTime.utc(2026, 7, 15, 0, 0, 30),
      ),
    );

    expect(decision.permitsResponseUse, isFalse);
    expect(decision.reasonCode, 'authorization_response_expired');
    expect(primitive.callCount, 0);
  });

  test('excessively future-issued authorization fails closed', () async {
    final _FakePrimitive primitive = _FakePrimitive(result: true);
    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(
      createContract(
        issuedAt: DateTime.utc(2026, 7, 15, 0, 1, 1),
        expiresAt: DateTime.utc(2026, 7, 15, 0, 2),
      ),
    );

    expect(decision.permitsResponseUse, isFalse);
    expect(decision.reasonCode, 'authorization_response_not_yet_valid');
    expect(primitive.callCount, 0);
  });

  test('cryptographically invalid signature fails closed', () async {
    final _FakePrimitive primitive = _FakePrimitive(result: false);
    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(createContract());

    expect(decision.permitsResponseUse, isFalse);
    expect(decision.reasonCode, 'authorization_signature_invalid');
    expect(primitive.callCount, 1);
  });

  test('malformed DER signature fails closed before primitive', () async {
    final _FakePrimitive primitive = _FakePrimitive(result: true);
    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(
      createContract(signature: base64Encode(<int>[0x30, 0x00])),
    );

    expect(decision.permitsResponseUse, isFalse);
    expect(decision.reasonCode, 'authorization_signature_verification_failed');
    expect(primitive.callCount, 0);
  });

  test('cryptographic primitive exception fails closed', () async {
    final _FakePrimitive primitive = _FakePrimitive(
      result: false,
      shouldThrow: true,
    );

    final CamoSignedAuthorizationContractV1Verifier verifier = createVerifier(
      primitive,
    );

    final decision = await verifier.verify(createContract());

    expect(decision.permitsResponseUse, isFalse);
    expect(decision.reasonCode, 'authorization_signature_verification_failed');
    expect(primitive.callCount, 1);
  });
}

final class _FakePrimitive implements CamoP256SignatureVerificationPrimitive {
  _FakePrimitive({required this.result, this.shouldThrow = false});

  final bool result;
  final bool shouldThrow;

  int callCount = 0;
  List<int> lastMessage = const <int>[];
  List<int> lastRawSignature = const <int>[];
  List<int> lastPublicKeyX = const <int>[];
  List<int> lastPublicKeyY = const <int>[];

  @override
  Future<bool> verify({
    required List<int> message,
    required List<int> rawSignature,
    required List<int> publicKeyX,
    required List<int> publicKeyY,
  }) async {
    callCount++;
    lastMessage = List<int>.of(message);
    lastRawSignature = List<int>.of(rawSignature);
    lastPublicKeyX = List<int>.of(publicKeyX);
    lastPublicKeyY = List<int>.of(publicKeyY);

    if (shouldThrow) {
      throw StateError('simulated_cryptographic_failure');
    }

    return result;
  }
}
