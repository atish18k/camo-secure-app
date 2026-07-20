// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import 'package:camo/core/crypto/encryption/camo_authorized_encode_material.dart';
import 'package:camo/core/crypto/encryption/camo_final_key_derivation.dart';
import 'package:camo/core/crypto/encryption/camo_standard_camo_encryptor.dart';
import 'package:camo/core/crypto/server_share/camo_server_share.dart';
import 'package:camo/core/crypto/server_share/camo_server_share_validator.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

final class _FakeFinalKeyDerivation implements CamoFinalKeyDerivation {
  int calls = 0;
  List<int>? lastInfo;

  @override
  Future<Uint8List> deriveFinalKey({
    required Uint8List deviceSharedSecret,
    required CamoServerShare serverShare,
    required Uint8List salt,
    required List<int> info,
  }) async {
    calls++;
    lastInfo = List<int>.from(info);
    return Uint8List.fromList(List<int>.filled(32, 5));
  }
}

final class _EncodeProbe {
  int calls = 0;
  Uint8List? lastKey;
  bool? lastCamouflageEnabled;

  Future<String> call({
    required String plainText,
    required Uint8List key,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    calls++;
    lastKey = Uint8List.fromList(key);
    lastCamouflageEnabled = camouflageEnabled;
    return 'encoded-standard-camo';
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  CamoAuthorizedEncodeMaterial material({
    String operationId = 'operation-001',
    String serverShareOperationId = 'operation-001',
    DateTime? serverTime,
    DateTime? expiresAt,
  }) {
    return CamoAuthorizedEncodeMaterial(
      operationId: operationId,
      messageId: 'message-001',
      pairingId: 'pairing-001',
      authorizationId: 'authorization-001',
      challengeId: 'challenge-001',
      serverTime: serverTime ?? DateTime.utc(2026, 7, 20),
      serverShare: CamoServerShare(
        shareId: 'share-001',
        operationId: serverShareOperationId,
        version: 1,
        expiresAt: expiresAt ?? DateTime.utc(2026, 7, 20, 0, 1),
        bytes: Uint8List.fromList(List<int>.filled(32, 9)),
      ),
      deviceSharedSecret: Uint8List.fromList(List<int>.filled(32, 4)),
      salt: Uint8List.fromList(List<int>.filled(32, 3)),
    );
  }

  test(
    'valid authorized material derives key then performs Standard CAMO',
    () async {
      final _FakeFinalKeyDerivation derivation = _FakeFinalKeyDerivation();
      final _EncodeProbe encoder = _EncodeProbe();

      final CamoStandardCamoEncryptor encryptor = CamoStandardCamoEncryptor(
        serverShareValidator: const CamoServerShareValidator(),
        finalKeyDerivation: derivation,
        messageEncoder: encoder.call,
      );

      final String output = await encryptor.encrypt(
        material: material(),
        plainText: 'secret',
      );

      expect(output, 'encoded-standard-camo');
      expect(derivation.calls, 1);
      expect(encoder.calls, 1);
      expect(encoder.lastKey, hasLength(32));
      expect(encoder.lastCamouflageEnabled, isFalse);
      expect(derivation.lastInfo, isNotEmpty);
    },
  );

  test('operation mismatch fails before derivation and encryption', () async {
    final _FakeFinalKeyDerivation derivation = _FakeFinalKeyDerivation();
    final _EncodeProbe encoder = _EncodeProbe();

    final CamoStandardCamoEncryptor encryptor = CamoStandardCamoEncryptor(
      serverShareValidator: const CamoServerShareValidator(),
      finalKeyDerivation: derivation,
      messageEncoder: encoder.call,
    );

    await expectLater(
      encryptor.encrypt(
        material: material(serverShareOperationId: 'operation-002'),
        plainText: 'secret',
      ),
      throwsStateError,
    );

    expect(derivation.calls, 0);
    expect(encoder.calls, 0);
  });

  test('expired server share fails before derivation and encryption', () async {
    final _FakeFinalKeyDerivation derivation = _FakeFinalKeyDerivation();
    final _EncodeProbe encoder = _EncodeProbe();

    final CamoStandardCamoEncryptor encryptor = CamoStandardCamoEncryptor(
      serverShareValidator: const CamoServerShareValidator(),
      finalKeyDerivation: derivation,
      messageEncoder: encoder.call,
    );

    await expectLater(
      encryptor.encrypt(
        material: material(
          serverTime: DateTime.utc(2026, 7, 20, 0, 1),
          expiresAt: DateTime.utc(2026, 7, 20, 0, 1),
        ),
        plainText: 'secret',
      ),
      throwsStateError,
    );

    expect(derivation.calls, 0);
    expect(encoder.calls, 0);
  });

  test('empty plaintext fails before derivation and encryption', () async {
    final _FakeFinalKeyDerivation derivation = _FakeFinalKeyDerivation();
    final _EncodeProbe encoder = _EncodeProbe();

    final CamoStandardCamoEncryptor encryptor = CamoStandardCamoEncryptor(
      serverShareValidator: const CamoServerShareValidator(),
      finalKeyDerivation: derivation,
      messageEncoder: encoder.call,
    );

    await expectLater(
      encryptor.encrypt(material: material(), plainText: ''),
      throwsStateError,
    );

    expect(derivation.calls, 0);
    expect(encoder.calls, 0);
  });
}
