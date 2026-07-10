// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_binary_serializer.dart';
import 'camo_crypto_payload.dart';

// ---------------------------------------------------------------------------
// Legacy Payload Formatter
// ---------------------------------------------------------------------------
//
// NOTE:
// This formatter is kept only for backward compatibility with older CAMO
// payloads that use the legacy CM1 text format.
//
// New compact payload production format will be handled by the Payload Engine.
// Do not remove this file until legacy decode migration is complete.
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
  // Encode Legacy Payload
  // ---------------------------------------------------------------------------

  String encode(
    CamoCryptoPayload payload,
  ) {
    final Uint8List bytes = _serializer.serialize(payload);
    final String encoded = base64UrlEncode(bytes);

    return '$protocolPrefix|$encoded';
  }

  // ---------------------------------------------------------------------------
  // Decode Legacy Payload
  // ---------------------------------------------------------------------------

  CamoCryptoPayload decode(
    String encodedPayload,
  ) {
    final List<String> parts = encodedPayload.split('|');

    if (parts.length != 2 || parts.first != protocolPrefix) {
      throw const FormatException(
        'Invalid legacy CAMO payload format.',
      );
    }

    final Uint8List bytes = Uint8List.fromList(
      base64Url.decode(parts.last),
    );

    return _serializer.deserialize(bytes);
  }
}