import 'dart:typed_data';

import '../../domain/entities/camo_payload_packet.dart';
import '../../domain/repositories/camo_payload_serializer.dart';

class CamoCompactPayloadSerializer implements CamoPayloadSerializer {
  static const int nonceLength = 12;
  static const int headerLength = 4;

  @override
  Uint8List serialize(CamoPayloadPacket packet) {
    final Uint8List metadata = packet.metadata ?? Uint8List(0);
    final int metadataLength = metadata.length;

    final int totalLength =
        packet.nonce.length + headerLength + metadataLength + packet.cipherText.length;

    final Uint8List bytes = Uint8List(totalLength);

    int offset = 0;

    bytes.setRange(offset, offset + packet.nonce.length, packet.nonce);
    offset += packet.nonce.length;

    bytes[offset] = packet.version;
    offset++;

    bytes[offset] = packet.flags;
    offset++;

    bytes[offset] = metadataLength >> 8;
    offset++;

    bytes[offset] = metadataLength & 0xff;
    offset++;

    bytes.setRange(offset, offset + metadataLength, metadata);
    offset += metadataLength;

    bytes.setRange(offset, offset + packet.cipherText.length, packet.cipherText);

    return bytes;
  }
}