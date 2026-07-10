import 'dart:typed_data';

import '../../domain/entities/camo_payload_packet.dart';
import '../../domain/repositories/camo_payload_parser.dart';

class CamoCompactPayloadParser implements CamoPayloadParser {
  static const int nonceLength = 12;
  static const int headerLength = 4;

  @override
  CamoPayloadPacket parse(Uint8List bytes) {
    if (bytes.length < nonceLength + headerLength) {
      throw const FormatException('Invalid CAMO payload packet.');
    }

    int offset = 0;

    final Uint8List nonce = Uint8List.fromList(
      bytes.sublist(offset, offset + nonceLength),
    );

    offset += nonceLength;

    final int version = bytes[offset];
    offset++;

    final int flags = bytes[offset];
    offset++;

    final int metadataLength = (bytes[offset] << 8) | bytes[offset + 1];
    offset += 2;

    final int minimumLength = nonceLength + headerLength + metadataLength;

    if (bytes.length < minimumLength) {
      throw const FormatException('Invalid CAMO payload metadata length.');
    }

    final Uint8List? metadata = metadataLength == 0
        ? null
        : Uint8List.fromList(
            bytes.sublist(offset, offset + metadataLength),
          );

    offset += metadataLength;

    final Uint8List cipherText = Uint8List.fromList(
      bytes.sublist(offset),
    );

    if (cipherText.isEmpty) {
      throw const FormatException('Invalid CAMO payload ciphertext.');
    }

    return CamoPayloadPacket(
      version: version,
      flags: flags,
      nonce: nonce,
      cipherText: cipherText,
      metadata: metadata,
    );
  }
}