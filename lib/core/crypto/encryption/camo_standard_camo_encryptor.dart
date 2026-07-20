// The public constructor intentionally keeps readable named parameters.
// Private-field initializing formals would expose private parameter names to
// importing libraries, so this narrowly scoped lint exception is deliberate.
// ignore_for_file: prefer_initializing_formals

// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import '../server_share/camo_server_share_validator.dart';
import 'camo_authorized_encode_material.dart';
import 'camo_final_key_derivation.dart';

// ---------------------------------------------------------------------------
// Standard CAMO Message Encoder
// ---------------------------------------------------------------------------

typedef CamoStandardMessageEncoder =
    Future<String> Function({
      required String plainText,
      required Uint8List key,
      String? subject,
      bool camouflageEnabled,
    });

// ---------------------------------------------------------------------------
// Standard CAMO Encryptor
// ---------------------------------------------------------------------------

final class CamoStandardCamoEncryptor {
  const CamoStandardCamoEncryptor({
    required CamoServerShareValidator serverShareValidator,
    required CamoFinalKeyDerivation finalKeyDerivation,
    required CamoStandardMessageEncoder messageEncoder,
  }) : _serverShareValidator = serverShareValidator,
       _finalKeyDerivation = finalKeyDerivation,
       _messageEncoder = messageEncoder;

  final CamoServerShareValidator _serverShareValidator;
  final CamoFinalKeyDerivation _finalKeyDerivation;
  final CamoStandardMessageEncoder _messageEncoder;

  Future<String> encrypt({
    required CamoAuthorizedEncodeMaterial material,
    required String plainText,
  }) async {
    if (!material.isValid) {
      throw StateError('Authorized encode material is invalid.');
    }

    if (plainText.isEmpty) {
      throw StateError('Plaintext is required.');
    }

    _serverShareValidator.validate(
      serverShare: material.serverShare,
      expectedOperationId: material.operationId,
      now: material.serverTime,
    );

    final List<int> info = utf8.encode(
      'CAMO|standard-encode|v1'
      '|${material.operationId.trim()}'
      '|${material.messageId.trim()}'
      '|${material.pairingId.trim()}'
      '|${material.authorizationId.trim()}'
      '|${material.challengeId.trim()}',
    );

    final Uint8List finalKey = await _finalKeyDerivation.deriveFinalKey(
      deviceSharedSecret: material.deviceSharedSecret,
      serverShare: material.serverShare,
      salt: material.salt,
      info: info,
    );

    if (finalKey.length != 32) {
      throw StateError('Standard CAMO final key must contain 32 bytes.');
    }

    return _messageEncoder(
      plainText: plainText,
      key: finalKey,
      camouflageEnabled: false,
    );
  }
}
