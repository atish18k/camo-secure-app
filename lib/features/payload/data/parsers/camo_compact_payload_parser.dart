import 'dart:typed_data';

import '../../domain/entities/camo_payload_packet.dart';
import '../../domain/repositories/camo_payload_parser.dart';

class CamoCompactPayloadParser implements CamoPayloadParser {
  static const int headerLength = 4;
  static const int nonceLength = 12;

  @override
  CamoPayloadPacket parse(Uint8List bytes) {
    if (bytes.length < headerLength + nonceLength) {
      throw const FormatException('Invalid CAMO payload packet.');
    }

    final int version = bytes[0];
    final int flags = bytes[1];
    final int metadataLength = (bytes[2] << 8) | bytes[3];

    final int minimumLength = headerLength + metadataLength + nonceLength;

    if (bytes.length < minimumLength) {
      throw const FormatException('Invalid CAMO payload metadata length.');
    }

    int offset = headerLength;

    final Uint8List? metadata = metadataLength == 0
        ? null
        : Uint8List.fromList(
            bytes.sublist(offset, offset + metadataLength),
          );

    offset += metadataLength;

    final Uint8List nonce = Uint8List.fromList(
      bytes.sublist(offset, offset + nonceLength),
    );

    offset += nonceLength;

    final Uint8List cipherText = Uint8List.fromList(
      bytes.sublist(offset),
    );

    if (cipherText.isEmpty) {
      throw const FormatException('Invalid CAMO payload ciphertext.');
    }

    return CamoPayloadPacket(
      version: version,
      flags: flags,
      metadata: metadata,
      nonce: nonce,
      cipherText: cipherText,
    );
  }
}