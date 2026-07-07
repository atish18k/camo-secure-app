// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';

import 'camo_crypto_payload.dart';

// ---------------------------------------------------------------------------
// Payload Formatter
// ---------------------------------------------------------------------------

class CamoPayloadFormatter {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String protocolPrefix = 'CM1';

  // ---------------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------------

  String encode(
    CamoCryptoPayload payload,
  ) {
    final Map<String, dynamic> map = {
      'v': payload.version,
      'alg': payload.algorithm,
      'n': payload.nonce,
      'ct': payload.cipherText,
      'tag': payload.authenticationTag,
      'ts': payload.createdAt.toUtc().toIso8601String(),
      'camo': payload.camouflageEnabled,
      'sub': payload.subject,
    };

    final String jsonPayload = jsonEncode(map);
    final String encodedPayload = base64UrlEncode(
      utf8.encode(jsonPayload),
    );

    return '$protocolPrefix|$encodedPayload';
  }

  // ---------------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------------

  CamoCryptoPayload decode(
    String encodedPayload,
  ) {
    final List<String> parts = encodedPayload.split('|');

    if (parts.length != 2 || parts.first != protocolPrefix) {
      throw const FormatException('Invalid CAMO payload format.');
    }

    final String jsonPayload = utf8.decode(
      base64Url.decode(parts.last),
    );

    final Map<String, dynamic> map =
        jsonDecode(jsonPayload) as Map<String, dynamic>;

    return CamoCryptoPayload(
      version: map['v'] as int? ?? 1,
      algorithm: map['alg'] as String? ?? '',
      nonce: map['n'] as String? ?? '',
      cipherText: map['ct'] as String? ?? '',
      authenticationTag: map['tag'] as String? ?? '',
      createdAt: DateTime.tryParse(
            map['ts'] as String? ?? '',
          )?.toUtc() ??
          DateTime.now().toUtc(),
      camouflageEnabled: map['camo'] as bool? ?? false,
      subject: map['sub'] as String?,
    );
  }
}