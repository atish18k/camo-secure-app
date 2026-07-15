import 'dart:convert';

/// Client-owned facts for a device registration request.
///
/// The client cannot select an approved or trusted state. Server resolution
/// fields are deliberately absent from this model and its serialization.
final class CamoDeviceRegistrationRequestModel {
  factory CamoDeviceRegistrationRequestModel({
    required String requestId,
    required String userId,
    required String deviceId,
    required String publicKey,
    required int keyVersion,
    required String platform,
    required DateTime requestedAt,
  }) {
    final normalizedRequestId = requestId.trim();
    final normalizedUserId = userId.trim();
    final normalizedDeviceId = deviceId.trim();
    final normalizedPublicKey = publicKey.trim();
    final normalizedPlatform = platform.trim();

    if (normalizedRequestId.isEmpty ||
        normalizedRequestId.contains('/') ||
        normalizedUserId.isEmpty ||
        normalizedUserId.contains('/') ||
        normalizedDeviceId.isEmpty ||
        normalizedDeviceId.contains('/') ||
        normalizedPublicKey.isEmpty ||
        normalizedPlatform.isEmpty ||
        keyVersion <= 0) {
      throw const FormatException(
        'Device registration request contains invalid client facts.',
      );
    }

    final List<int> decodedPublicKey;
    try {
      decodedPublicKey = base64Decode(normalizedPublicKey);
    } on FormatException {
      throw const FormatException(
        'Device registration request public key is invalid.',
      );
    }
    if (decodedPublicKey.length != 32) {
      throw const FormatException(
        'Device registration request requires a 32-byte X25519 public key.',
      );
    }

    return CamoDeviceRegistrationRequestModel._(
      requestId: normalizedRequestId,
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
      publicKey: normalizedPublicKey,
      keyVersion: keyVersion,
      platform: normalizedPlatform,
      requestedAt: requestedAt.toUtc(),
    );
  }

  const CamoDeviceRegistrationRequestModel._({
    required this.requestId,
    required this.userId,
    required this.deviceId,
    required this.publicKey,
    required this.keyVersion,
    required this.platform,
    required this.requestedAt,
  });

  static const int schemaVersion = 1;
  static const String pendingStatus = 'pending';

  final String requestId;
  final String userId;
  final String deviceId;
  final String publicKey;
  final int keyVersion;
  final String platform;
  final DateTime requestedAt;

  String get status => pendingStatus;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'requestId': requestId,
      'userId': userId,
      'deviceId': deviceId,
      'publicKey': publicKey,
      'keyVersion': keyVersion,
      'platform': platform,
      'status': pendingStatus,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }
}
