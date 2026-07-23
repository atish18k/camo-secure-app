// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import '../../../features/payload/domain/entities/camo_payload_packet.dart';
import '../../../features/payload/domain/repositories/camo_payload_parser.dart';
import '../../../features/payload/domain/repositories/camo_payload_serializer.dart';
import 'camo_crypto_engine.dart';
import 'camo_nonce_generator.dart';

// ---------------------------------------------------------------------------
// Message Crypto Service
// ---------------------------------------------------------------------------

class CamoMessageCryptoService {
  const CamoMessageCryptoService({
    required this.cryptoEngine,
    required this.nonceGenerator,
    required this.payloadSerializer,
    required this.payloadParser,
  });

  final CamoCryptoEngine cryptoEngine;
  final CamoNonceGenerator nonceGenerator;
  final CamoPayloadSerializer payloadSerializer;
  final CamoPayloadParser payloadParser;

  Future<String> encode({
    required String plainText,
    required Uint8List key,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    final Uint8List nonce = nonceGenerator.generateNonce();

    final Uint8List encryptedBytes = await cryptoEngine.encrypt(
      plainText: Uint8List.fromList(utf8.encode(plainText)),
      key: key,
      nonce: nonce,
    );

    final CamoPayloadPacket packet = CamoPayloadPacket(
      version: 1,
      flags: 0,
      nonce: nonce,
      cipherText: encryptedBytes,
    );

    final Uint8List packetBytes = payloadSerializer.serialize(packet);

    return base64UrlEncode(packetBytes);
  }

  Future<String> decode({
    required String encodedText,
    required Uint8List key,
  }) async {
    final String normalizedEncodedText = encodedText.trim();
    if (normalizedEncodedText.isEmpty) {
      throw StateError('Only strict CAMO V2 payloads are accepted.');
    }

    return _decodeCompact(encodedText: normalizedEncodedText, key: key);
  }

  Future<String> _decodeCompact({
    required String encodedText,
    required Uint8List key,
  }) async {
    final Uint8List packetBytes = Uint8List.fromList(
      base64Url.decode(encodedText),
    );

    final CamoPayloadPacket packet = payloadParser.parse(packetBytes);

    final Uint8List plainTextBytes = await cryptoEngine.decrypt(
      cipherText: packet.cipherText,
      key: key,
      nonce: packet.nonce,
    );

    return utf8.decode(plainTextBytes);
  }

  Future<String> decodeV2Only({
    required String encodedText,
    required Uint8List key,
  }) {
    return decode(encodedText: encodedText, key: key);
  }
}
