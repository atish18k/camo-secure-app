// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';

// ---------------------------------------------------------------------------
// QR Payload
// ---------------------------------------------------------------------------

class QrPayload {
  const QrPayload({
    required this.version,
    required this.camoId,
  });

  final String version;
  final String camoId;
}

// ---------------------------------------------------------------------------
// QR Payload Parser
// ---------------------------------------------------------------------------

class QrPayloadParser {
  QrPayload parse(String payload) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;

      final Object? version = data['v'] ?? data['version'];
      final Object? type = data['t'] ?? data['type'];
      final Object? identity = data['id'] ?? data['identity'];

      if (version.toString() != '1') {
        throw const FormatException('Unsupported QR version.');
      }

      if (type != 'identity') {
        throw const FormatException('Invalid CAMO QR type.');
      }

      if (identity is! String || identity.trim().isEmpty) {
        throw const FormatException('Missing CAMO ID.');
      }

      return QrPayload(
        version: version.toString(),
        camoId: identity.trim().toUpperCase(),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid QR payload.');
    }
  }
}