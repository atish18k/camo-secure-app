import 'dart:typed_data';

class CamoPayloadPacket {
  const CamoPayloadPacket({
    required this.version,
    required this.flags,
    required this.nonce,
    required this.cipherText,
    this.metadata,
  });

  final int version;
  final int flags;
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List? metadata;

  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;
}