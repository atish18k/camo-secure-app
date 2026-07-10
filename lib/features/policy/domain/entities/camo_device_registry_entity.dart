// ---------------------------------------------------------------------------
// CAMO Device Registry Entity
// ---------------------------------------------------------------------------

/// Trusted device registration record.
///
/// This entity represents a registered device only.
///
/// It must never contain:
///
/// - private keys
/// - shared secrets
/// - derived encryption keys
/// - plaintext
class CamoDeviceRegistryEntity {
  const CamoDeviceRegistryEntity({
    required this.deviceId,
    required this.userId,
    required this.publicKey,
    required this.platform,
    required this.status,
    required this.keyVersion,
    required this.createdAt,
    required this.lastSeenAt,
  });

  /// Random device identifier (UUID v4).
  final String deviceId;

  /// Owner user id.
  final String userId;

  /// Base64 encoded X25519 public key.
  final String publicKey;

  /// Android / iOS / Windows / Linux / macOS / Web.
  final String platform;

  /// Device lifecycle status.
  final CamoDeviceStatus status;

  /// Public-key version.
  final int keyVersion;

  /// Registration timestamp.
  final DateTime createdAt;

  /// Last successful policy validation.
  final DateTime lastSeenAt;

  bool get isActive => status == CamoDeviceStatus.active;

  bool get isRevoked => status == CamoDeviceStatus.revoked;

  bool get isBlocked => status == CamoDeviceStatus.blocked;
}

// ---------------------------------------------------------------------------
// Device Status
// ---------------------------------------------------------------------------

enum CamoDeviceStatus {
  active,
  revoked,
  blocked,
}