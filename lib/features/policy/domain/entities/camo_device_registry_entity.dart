import '../../../../core/device_trust/domain/entities/camo_device_status.dart';

/// Canonical trusted-device registration record.
///
/// Private keys, shared secrets, derived keys, plaintext, and decrypted
/// content must never be stored in this entity.
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

  final String deviceId;
  final String userId;
  final String publicKey;
  final String platform;
  final CamoDeviceStatus status;
  final int keyVersion;
  final DateTime createdAt;

  /// Internal view of the server-controlled canonical `updatedAt` timestamp.
  /// The client never writes this value to a trusted-device document.
  final DateTime lastSeenAt;

  bool get isApproved => status == CamoDeviceStatus.approved;
  bool get isRevoked => status == CamoDeviceStatus.revoked;
  bool get isBlocked => status.isBlocked;
}
