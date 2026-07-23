import 'dart:typed_data';

import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:camo/core/authorization_gateway/data/models/camo_verified_signed_permit_projection_v2.dart';
import 'package:camo/core/authorization_gateway/domain/repositories/camo_verified_v2_permit_store.dart';
import 'package:camo/core/crypto/encryption/camo_decode_key_material.dart';
import 'package:camo/core/crypto/encryption/camo_decode_key_material_provider.dart';
import 'package:camo/core/crypto/encryption/camo_final_key_derivation.dart';
import 'package:camo/core/crypto/encryption/camo_standard_uncamo_decryptor.dart';
import 'package:camo/core/crypto/encryption/camo_verified_v2_uncamo_runtime.dart';
import 'package:camo/core/crypto/server_share/camo_server_share.dart';
import 'package:camo/core/crypto/server_share/camo_server_share_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('consumes verified permit and completes authorized UNCAMO', () async {
    final _PermitStore store = _PermitStore(_permit());
    final _KeyMaterialProvider provider = _KeyMaterialProvider();
    final _FinalKeyDerivation derivation = _FinalKeyDerivation();

    final CamoVerifiedV2UncamoRuntime runtime = CamoVerifiedV2UncamoRuntime(
      permitStore: store,
      keyMaterialProvider: provider,
      decryptor: CamoStandardUncamoDecryptor(
        serverShareValidator: const CamoServerShareValidator(),
        finalKeyDerivation: derivation,
        messageDecoder:
            ({required String encodedText, required Uint8List key}) async {
              expect(encodedText, 'encoded');
              expect(key, hasLength(32));
              return 'plaintext';
            },
      ),
      clock: () => DateTime.utc(2026, 7, 23, 10, 1),
    );

    final String output = await runtime.decrypt(
      requestId: 'request-1',
      operationId: 'operation-1',
      messageId: 'message-1',
      pairingId: 'pair-1',
      encodedText: 'encoded',
    );

    expect(output, 'plaintext');
    expect(store.consumeCalls, 1);
    expect(provider.calls, 1);
    expect(derivation.calls, 1);
  });

  test('missing permit fails before key-material resolution', () async {
    final _PermitStore store = _PermitStore(null);
    final _KeyMaterialProvider provider = _KeyMaterialProvider();

    final CamoVerifiedV2UncamoRuntime runtime = _runtime(
      store: store,
      provider: provider,
    );

    await expectLater(
      runtime.decrypt(
        requestId: 'request-1',
        operationId: 'operation-1',
        messageId: 'message-1',
        pairingId: 'pair-1',
        encodedText: 'encoded',
      ),
      throwsStateError,
    );

    expect(provider.calls, 0);
  });

  test(
    'message mismatch fails closed before key-material resolution',
    () async {
      final _PermitStore store = _PermitStore(_permit());
      final _KeyMaterialProvider provider = _KeyMaterialProvider();

      final CamoVerifiedV2UncamoRuntime runtime = _runtime(
        store: store,
        provider: provider,
      );

      await expectLater(
        runtime.decrypt(
          requestId: 'request-1',
          operationId: 'operation-1',
          messageId: 'message-wrong',
          pairingId: 'pair-1',
          encodedText: 'encoded',
        ),
        throwsStateError,
      );

      expect(provider.calls, 0);
    },
  );

  test('expired permit fails before key-material resolution', () async {
    final _PermitStore store = _PermitStore(_permit());
    final _KeyMaterialProvider provider = _KeyMaterialProvider();

    final CamoVerifiedV2UncamoRuntime runtime = _runtime(
      store: store,
      provider: provider,
      clock: () => DateTime.utc(2026, 7, 23, 10, 6),
    );

    await expectLater(
      runtime.decrypt(
        requestId: 'request-1',
        operationId: 'operation-1',
        messageId: 'message-1',
        pairingId: 'pair-1',
        encodedText: 'encoded',
      ),
      throwsStateError,
    );

    expect(provider.calls, 0);
  });

  test('empty input fails before permit consumption', () async {
    final _PermitStore store = _PermitStore(_permit());

    final CamoVerifiedV2UncamoRuntime runtime = _runtime(store: store);

    await expectLater(
      runtime.decrypt(
        requestId: '',
        operationId: 'operation-1',
        messageId: 'message-1',
        pairingId: 'pair-1',
        encodedText: 'encoded',
      ),
      throwsStateError,
    );

    expect(store.consumeCalls, 0);
  });
}

CamoVerifiedV2UncamoRuntime _runtime({
  required _PermitStore store,
  _KeyMaterialProvider? provider,
  DateTime Function()? clock,
}) {
  return CamoVerifiedV2UncamoRuntime(
    permitStore: store,
    keyMaterialProvider: provider ?? _KeyMaterialProvider(),
    decryptor: CamoStandardUncamoDecryptor(
      serverShareValidator: const CamoServerShareValidator(),
      finalKeyDerivation: _FinalKeyDerivation(),
      messageDecoder:
          ({required String encodedText, required Uint8List key}) async {
            return 'plaintext';
          },
    ),
    clock: clock ?? () => DateTime.utc(2026, 7, 23, 10, 1),
  );
}

CamoVerifiedSignedPermitProjectionV2 _permit() {
  return CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(
    CamoSignedAuthorizationContractV2(
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
    ),
  );
}

final class _PermitStore implements CamoVerifiedV2PermitStore {
  _PermitStore(this.permit);

  final CamoVerifiedSignedPermitProjectionV2? permit;
  int consumeCalls = 0;

  @override
  Future<CamoVerifiedSignedPermitProjectionV2?> consume({
    required String requestId,
    required String operationId,
  }) async {
    consumeCalls++;
    return permit;
  }

  @override
  Future<void> save({
    required String requestId,
    required CamoVerifiedSignedPermitProjectionV2 permit,
  }) async {}

  @override
  Future<void> remove({required String requestId}) async {}

  @override
  Future<void> clear() async {}
}

final class _KeyMaterialProvider implements CamoDecodeKeyMaterialProvider {
  int calls = 0;

  @override
  Future<CamoDecodeKeyMaterial> resolve({required String pairingId}) async {
    calls++;
    return CamoDecodeKeyMaterial(
      deviceSharedSecret: Uint8List.fromList(List<int>.filled(32, 4)),
      salt: Uint8List.fromList(List<int>.filled(16, 3)),
    );
  }
}

final class _FinalKeyDerivation implements CamoFinalKeyDerivation {
  int calls = 0;

  @override
  Future<Uint8List> deriveFinalKey({
    required Uint8List deviceSharedSecret,
    required CamoServerShare serverShare,
    required Uint8List salt,
    required List<int> info,
  }) async {
    calls++;
    return Uint8List.fromList(List<int>.filled(32, 7));
  }
}
