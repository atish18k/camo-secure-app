final class CamoAuthorizationResponseSignaturePayload {
  const CamoAuthorizationResponseSignaturePayload({
    required this.responseId,
    required this.requestId,
    required this.operationId,
    required this.sessionId,
    required this.keyReleaseId,
    required this.serverTime,
  });

  final String responseId;
  final String requestId;
  final String operationId;
  final String sessionId;
  final String keyReleaseId;
  final DateTime serverTime;

  bool get isValid {
    return responseId.trim().isNotEmpty &&
        requestId.trim().isNotEmpty &&
        operationId.trim().isNotEmpty &&
        sessionId.trim().isNotEmpty &&
        keyReleaseId.trim().isNotEmpty;
  }

  String toCanonicalString() {
    if (!isValid) {
      throw StateError('Authorization response signature payload is invalid.');
    }

    return <String>[
      'responseId=${responseId.trim()}',
      'requestId=${requestId.trim()}',
      'operationId=${operationId.trim()}',
      'sessionId=${sessionId.trim()}',
      'keyReleaseId=${keyReleaseId.trim()}',
      'serverTime=${serverTime.toUtc().toIso8601String()}',
    ].join('\n');
  }
}
