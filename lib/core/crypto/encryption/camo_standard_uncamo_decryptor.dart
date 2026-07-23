// The public constructor intentionally keeps readable named parameters.
// ignore_for_file: prefer_initializing_formals

// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../server_share/camo_server_share_validator.dart';
import 'camo_authorized_decode_material.dart';
import 'camo_final_key_derivation.dart';
import 'camo_standard_crypto_context_v2.dart';

// ---------------------------------------------------------------------------
// Standard UNCAMO Message Decoder
// ---------------------------------------------------------------------------

typedef CamoStandardMessageDecoder =
    Future<String> Function({
      required String encodedText,
      required Uint8List key,
    });

// ---------------------------------------------------------------------------
// Standard UNCAMO Decryptor
// ---------------------------------------------------------------------------

final class CamoStandardUncamoDecryptor {
  const CamoStandardUncamoDecryptor({
    required CamoServerShareValidator serverShareValidator,
    required CamoFinalKeyDerivation finalKeyDerivation,
    required CamoStandardMessageDecoder messageDecoder,
  }) : _serverShareValidator = serverShareValidator,
       _finalKeyDerivation = finalKeyDerivation,
       _messageDecoder = messageDecoder;

  final CamoServerShareValidator _serverShareValidator;
  final CamoFinalKeyDerivation _finalKeyDerivation;
  final CamoStandardMessageDecoder _messageDecoder;

  Future<String> decrypt({
    required CamoAuthorizedDecodeMaterial material,
    required String encodedText,
  }) async {
    if (!material.isValid) {
      throw StateError('Authorized decode material is invalid.');
    }

    if (encodedText.trim().isEmpty) {
      throw StateError('Encoded text is required.');
    }

    _serverShareValidator.validate(
      serverShare: material.serverShare,
      expectedOperationId: material.operationId,
      now: material.serverTime,
    );

    final List<int> info = CamoStandardCryptoContextV2.build(
      operationId: material.operationId,
      messageId: material.messageId,
      pairingId: material.pairingId,
      authorizationId: material.authorizationId,
      challengeId: material.challengeId,
    );

    final Uint8List finalKey = await _finalKeyDerivation.deriveFinalKey(
      deviceSharedSecret: material.deviceSharedSecret,
      serverShare: material.serverShare,
      salt: material.salt,
      info: info,
    );

    if (finalKey.length != 32) {
      throw StateError('Standard UNCAMO final key must contain 32 bytes.');
    }

    final String plainText = await _messageDecoder(
      encodedText: encodedText,
      key: finalKey,
    );

    if (plainText.isEmpty) {
      throw StateError('Standard UNCAMO plaintext is empty.');
    }

    return plainText;
  }
}
