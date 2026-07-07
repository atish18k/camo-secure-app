// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_binary_serializer.dart';
import 'camo_crypto_payload.dart';

// ---------------------------------------------------------------------------
// Payload Formatter
// ---------------------------------------------------------------------------

class CamoPayloadFormatter {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  CamoPayloadFormatter({
    CamoBinarySerializer? serializer,
  }) : _serializer = serializer ?? CamoBinarySerializer();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String protocolPrefix = 'CM1';

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final CamoBinarySerializer _serializer;

  // ---------------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------------

  String encode(
    CamoCryptoPayload payload,
  ) {
    final Uint8List bytes = _serializer.serialize(payload);

    final String encoded = base64UrlEncode(bytes);

    return '$protocolPrefix|$encoded';
  }

  // ---------------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------------

  CamoCryptoPayload decode(
    String encodedPayload,
  ) {
    final List<String> parts = encodedPayload.split('|');

    if (parts.length != 2 || parts.first != protocolPrefix) {
      throw const FormatException(
        'Invalid CAMO payload format.',
      );
    }

    final Uint8List bytes = Uint8List.fromList(
      base64Url.decode(parts.last),
    );

    return _serializer.deserialize(bytes);
  }
}