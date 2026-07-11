// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoWrappedKeyMaterial {
  CamoWrappedKeyMaterial({
    required this.releaseId,
    required this.keyId,
    required this.wrappedKey,
    required this.wrappingAlgorithm,
    required this.deviceId,
    required this.createdAt,
    required this.expiresAt,
    Map<String, String> metadata = const <String, String>{},
  }) : metadata = Map<String, String>.unmodifiable(metadata);
  final String releaseId;
  final String keyId;
  final String wrappedKey;
  final String wrappingAlgorithm;
  final String deviceId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, String> metadata;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get isBoundToDevice {
    return deviceId.isNotEmpty;
  }

  bool get isUsable {
    return wrappedKey.isNotEmpty &&
        wrappingAlgorithm.isNotEmpty &&
        isBoundToDevice &&
        !isExpired;
  }
}
