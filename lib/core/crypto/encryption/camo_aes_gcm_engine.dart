// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'camo_crypto_engine.dart';

// ---------------------------------------------------------------------------
// AES-GCM Crypto Engine
// ---------------------------------------------------------------------------

class CamoAesGcmEngine implements CamoCryptoEngine {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const int macLength = 16;

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final AesGcm _aesGcm = AesGcm.with256bits();

  // ---------------------------------------------------------------------------
  // Encrypt
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> encrypt({
    required Uint8List plainText,
    required Uint8List key,
    required Uint8List nonce,
  }) async {
    final SecretBox secretBox = await _aesGcm.encrypt(
      plainText,
      secretKey: SecretKey(key),
      nonce: nonce,
    );

    return Uint8List.fromList(
      <int>[
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Decrypt
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> decrypt({
    required Uint8List cipherText,
    required Uint8List key,
    required Uint8List nonce,
  }) async {
    if (cipherText.length <= macLength) {
      throw const FormatException('Invalid encrypted payload.');
    }

    final int encryptedLength = cipherText.length - macLength;

    final SecretBox secretBox = SecretBox(
      cipherText.sublist(0, encryptedLength),
      nonce: nonce,
      mac: Mac(
        cipherText.sublist(encryptedLength),
      ),
    );

    final List<int> plainText = await _aesGcm.decrypt(
      secretBox,
      secretKey: SecretKey(key),
    );

    return Uint8List.fromList(plainText);
  }
}