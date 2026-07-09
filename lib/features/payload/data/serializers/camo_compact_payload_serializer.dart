import 'dart:typed_data';

import '../../domain/entities/camo_payload_packet.dart';
import '../../domain/repositories/camo_payload_serializer.dart';

class CamoCompactPayloadSerializer implements CamoPayloadSerializer {
  static const int headerLength = 4;

  @override
  Uint8List serialize(CamoPayloadPacket packet) {
    final Uint8List metadata = packet.metadata ?? Uint8List(0);
    final int metadataLength = metadata.length;

    final int totalLength = headerLength +
        metadataLength +
        packet.nonce.length +
        packet.cipherText.length;

    final Uint8List bytes = Uint8List(totalLength);

    bytes[0] = packet.version;
    bytes[1] = packet.flags;
    bytes[2] = metadataLength >> 8;
    bytes[3] = metadataLength & 0xff;

    int offset = headerLength;

    bytes.setRange(offset, offset + metadataLength, metadata);
    offset += metadataLength;

    bytes.setRange(offset, offset + packet.nonce.length, packet.nonce);
    offset += packet.nonce.length;

    bytes.setRange(offset, offset + packet.cipherText.length, packet.cipherText);

    return bytes;
  }
}