// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

final class CamoAuthorizationTransportResponse {
  const CamoAuthorizationTransportResponse({
    required this.statusCode,
    required this.payload,
    required this.headers,
  });

  final int statusCode;
  final Map<String, Object?> payload;
  final Map<String, String> headers;

  bool get isSuccessful {
    return statusCode >= 200 && statusCode < 300;
  }

  bool get isValid {
    return statusCode >= 100 &&
        statusCode <= 599 &&
        payload.isNotEmpty &&
        headers.keys.every((String key) => key.trim().isNotEmpty);
  }
}
