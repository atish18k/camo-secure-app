import 'dart:typed_data';

import 'package:camo/core/crypto/encryption/camo_authorized_decode_material.dart';
import 'package:camo/core/crypto/encryption/camo_final_key_derivation.dart';
import 'package:camo/core/crypto/encryption/camo_standard_uncamo_decryptor.dart';
import 'package:camo/core/crypto/server_share/camo_server_share.dart';
import 'package:camo/core/crypto/server_share/camo_server_share_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CamoStandardUncamoDecryptor', () {
    test(
      'valid authorized material derives key then decodes plaintext',
      () async {
        final _RecordingFinalKeyDerivation derivation =
            _RecordingFinalKeyDerivation(
              Uint8List.fromList(List<int>.filled(32, 7)),
            );

        Uint8List? decoderKey;

        final CamoStandardUncamoDecryptor decryptor =
            CamoStandardUncamoDecryptor(
              serverShareValidator: const CamoServerShareValidator(),
              finalKeyDerivation: derivation,
              messageDecoder:
                  ({
                    required String encodedText,
                    required Uint8List key,
                  }) async {
                    expect(encodedText, 'encoded-payload');
                    decoderKey = Uint8List.fromList(key);
                    return 'original plaintext';
                  },
            );

        final String result = await decryptor.decrypt(
          material: _validMaterial(),
          encodedText: 'encoded-payload',
        );

        expect(result, 'original plaintext');
        expect(decoderKey, isNotNull);
        expect(decoderKey, orderedEquals(List<int>.filled(32, 7)));
        expect(derivation.lastInfoText, contains('CAMO|standard-message|v2'));
        expect(derivation.lastInfoText, contains('|operation-1'));
        expect(derivation.lastInfoText, contains('|message-1'));
        expect(derivation.lastInfoText, contains('|pair-1'));
      },
    );

    test('operation mismatch fails before derivation and decode', () async {
      final _RecordingFinalKeyDerivation derivation =
          _RecordingFinalKeyDerivation(
            Uint8List.fromList(List<int>.filled(32, 7)),
          );

      bool decoderCalled = false;

      final CamoStandardUncamoDecryptor decryptor = CamoStandardUncamoDecryptor(
        serverShareValidator: const CamoServerShareValidator(),
        finalKeyDerivation: derivation,
        messageDecoder:
            ({required String encodedText, required Uint8List key}) async {
              decoderCalled = true;
              return 'unexpected';
            },
      );

      final CamoAuthorizedDecodeMaterial material = _validMaterial(
        serverShareOperationId: 'other-operation',
      );

      await expectLater(
        decryptor.decrypt(material: material, encodedText: 'encoded-payload'),
        throwsStateError,
      );

      expect(derivation.callCount, 0);
      expect(decoderCalled, isFalse);
    });

    test('expired ServerShare fails before derivation and decode', () async {
      final _RecordingFinalKeyDerivation derivation =
          _RecordingFinalKeyDerivation(
            Uint8List.fromList(List<int>.filled(32, 7)),
          );

      bool decoderCalled = false;

      final CamoStandardUncamoDecryptor decryptor = CamoStandardUncamoDecryptor(
        serverShareValidator: const CamoServerShareValidator(),
        finalKeyDerivation: derivation,
        messageDecoder:
            ({required String encodedText, required Uint8List key}) async {
              decoderCalled = true;
              return 'unexpected';
            },
      );

      await expectLater(
        decryptor.decrypt(
          material: _validMaterial(
            serverShareExpiresAt: DateTime.utc(2026, 7, 23, 9),
          ),
          encodedText: 'encoded-payload',
        ),
        throwsStateError,
      );

      expect(derivation.callCount, 0);
      expect(decoderCalled, isFalse);
    });

    test('empty encoded text fails before derivation', () async {
      final _RecordingFinalKeyDerivation derivation =
          _RecordingFinalKeyDerivation(
            Uint8List.fromList(List<int>.filled(32, 7)),
          );

      final CamoStandardUncamoDecryptor decryptor = CamoStandardUncamoDecryptor(
        serverShareValidator: const CamoServerShareValidator(),
        finalKeyDerivation: derivation,
        messageDecoder:
            ({required String encodedText, required Uint8List key}) async =>
                'unexpected',
      );

      await expectLater(
        decryptor.decrypt(material: _validMaterial(), encodedText: '   '),
        throwsStateError,
      );

      expect(derivation.callCount, 0);
    });

    test('non-32-byte final key fails before message decode', () async {
      final _RecordingFinalKeyDerivation derivation =
          _RecordingFinalKeyDerivation(
            Uint8List.fromList(List<int>.filled(31, 7)),
          );

      bool decoderCalled = false;

      final CamoStandardUncamoDecryptor decryptor = CamoStandardUncamoDecryptor(
        serverShareValidator: const CamoServerShareValidator(),
        finalKeyDerivation: derivation,
        messageDecoder:
            ({required String encodedText, required Uint8List key}) async {
              decoderCalled = true;
              return 'unexpected';
            },
      );

      await expectLater(
        decryptor.decrypt(
          material: _validMaterial(),
          encodedText: 'encoded-payload',
        ),
        throwsStateError,
      );

      expect(decoderCalled, isFalse);
    });
  });
}

CamoAuthorizedDecodeMaterial _validMaterial({
  String serverShareOperationId = 'operation-1',
  DateTime? serverShareExpiresAt,
}) {
  return CamoAuthorizedDecodeMaterial(
    operationId: 'operation-1',
    messageId: 'message-1',
    pairingId: 'pair-1',
    authorizationId: 'authorization-1',
    challengeId: 'challenge-1',
    serverTime: DateTime.utc(2026, 7, 23, 10),
    serverShare: CamoServerShare(
      shareId: 'share-1',
      operationId: serverShareOperationId,
      version: 1,
      expiresAt: serverShareExpiresAt ?? DateTime.utc(2026, 7, 23, 10, 5),
      bytes: Uint8List.fromList(List<int>.generate(32, (int i) => i)),
    ),
    deviceSharedSecret: Uint8List.fromList(
      List<int>.generate(32, (int i) => 100 + i),
    ),
    salt: Uint8List.fromList(List<int>.generate(16, (int i) => 200 + i)),
  );
}

final class _RecordingFinalKeyDerivation implements CamoFinalKeyDerivation {
  _RecordingFinalKeyDerivation(this.result);

  final Uint8List result;
  int callCount = 0;
  String lastInfoText = '';

  @override
  Future<Uint8List> deriveFinalKey({
    required Uint8List deviceSharedSecret,
    required CamoServerShare serverShare,
    required Uint8List salt,
    required List<int> info,
  }) async {
    callCount += 1;
    lastInfoText = String.fromCharCodes(info);
    return Uint8List.fromList(result);
  }
}
