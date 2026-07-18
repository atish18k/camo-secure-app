import 'dart:convert';

class QrPayload {
  const QrPayload({required this.version, required this.camoId});

  final int version;
  final String camoId;
}

class QrPayloadParser {
  static const Set<String> _requiredKeys = <String>{'v', 't', 'id'};

  QrPayload parse(String payload) {
    try {
      final Object? decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid QR payload.');
      }
      if (decoded.keys.toSet().length != _requiredKeys.length ||
          !decoded.keys.toSet().containsAll(_requiredKeys)) {
        throw const FormatException('Unknown or missing CAMO QR fields.');
      }
      if (decoded['v'] != 1) {
        throw const FormatException('Unsupported CAMO QR version.');
      }
      if (decoded['t'] != 'identity') {
        throw const FormatException('Invalid CAMO QR type.');
      }
      final Object? identity = decoded['id'];
      if (identity is! String ||
          identity.trim().isEmpty ||
          identity.length > 128 ||
          identity.contains(RegExp(r'[\x00-\x1F/\\]'))) {
        throw const FormatException('Invalid CAMO ID.');
      }
      return QrPayload(version: 1, camoId: identity.trim().toUpperCase());
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid QR payload.');
    }
  }
}
