// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_crypto_engine.dart';
import 'camo_crypto_payload.dart';
import 'camo_nonce_generator.dart';
import 'camo_payload_formatter.dart';

// ---------------------------------------------------------------------------
// Message Crypto Service
// ---------------------------------------------------------------------------

class CamoMessageCryptoService {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoMessageCryptoService({
    required this.cryptoEngine,
    required this.nonceGenerator,
    required this.payloadFormatter,
  });

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final CamoCryptoEngine cryptoEngine;
  final CamoNonceGenerator nonceGenerator;
  final CamoPayloadFormatter payloadFormatter;

  // ---------------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------------

  Future<String> encode({
    required String plainText,
    required Uint8List key,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    final Uint8List nonce = nonceGenerator.generateNonce();

    final Uint8List encryptedBytes = await cryptoEngine.encrypt(
      plainText: Uint8List.fromList(
        utf8.encode(plainText),
      ),
      key: key,
      nonce: nonce,
    );

    final int tagStartIndex = encryptedBytes.length - 16;

    final Uint8List cipherText = encryptedBytes.sublist(
      0,
      tagStartIndex,
    );

    final Uint8List authenticationTag = encryptedBytes.sublist(
      tagStartIndex,
    );

    final CamoCryptoPayload payload = CamoCryptoPayload(
      version: 1,
      algorithm: 'AES-256-GCM',
      nonce: base64UrlEncode(nonce),
      cipherText: base64UrlEncode(cipherText),
      authenticationTag: base64UrlEncode(authenticationTag),
      createdAt: DateTime.now().toUtc(),
      subject: subject,
      camouflageEnabled: camouflageEnabled,
    );

    return payloadFormatter.encode(payload);
  }

  // ---------------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------------

  Future<String> decode({
    required String encodedText,
    required Uint8List key,
  }) async {
    final CamoCryptoPayload payload = payloadFormatter.decode(encodedText);

    final Uint8List cipherText = base64Url.decode(payload.cipherText);
    final Uint8List authenticationTag =
        base64Url.decode(payload.authenticationTag);

    final Uint8List encryptedBytes = Uint8List.fromList(
      <int>[
        ...cipherText,
        ...authenticationTag,
      ],
    );

    final Uint8List plainTextBytes = await cryptoEngine.decrypt(
      cipherText: encryptedBytes,
      key: key,
      nonce: base64Url.decode(payload.nonce),
    );

    return utf8.decode(plainTextBytes);
  }
}