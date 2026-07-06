// ---------------------------------------------------------------------------
// QR Payload
// ---------------------------------------------------------------------------

class QrPayload {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const QrPayload({
    required this.version,
    required this.camoId,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String version;
  final String camoId;
}

// ---------------------------------------------------------------------------
// QR Payload Parser
// ---------------------------------------------------------------------------

class QrPayloadParser {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String _prefix = 'CAMO://PAIR';

  // ---------------------------------------------------------------------------
  // Parse
  // ---------------------------------------------------------------------------

  QrPayload parse(String payload) {
    final Uri? uri = Uri.tryParse(payload);

    if (uri == null) {
      throw const FormatException('Invalid QR payload.');
    }

    if (!payload.startsWith(_prefix)) {
      throw const FormatException('Invalid CAMO QR.');
    }

    final String? version = uri.queryParameters['version'];
    final String? camoId = uri.queryParameters['id'];

    if (version == null || version != '1') {
      throw const FormatException('Unsupported QR version.');
    }

    if (camoId == null || camoId.isEmpty) {
      throw const FormatException('Missing CAMO ID.');
    }

    return QrPayload(
      version: version,
      camoId: camoId,
    );
  }
}