// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/camo_device_registry_entity.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registry Model
// ---------------------------------------------------------------------------

class CamoDeviceRegistryModel extends CamoDeviceRegistryEntity {
  const CamoDeviceRegistryModel({
    required super.deviceId,
    required super.userId,
    required super.publicKey,
    required super.platform,
    required super.status,
    required super.keyVersion,
    required super.createdAt,
    required super.lastSeenAt,
  });

  // ---------------------------------------------------------------------------
  // Firestore Mapping
  // ---------------------------------------------------------------------------

  factory CamoDeviceRegistryModel.fromMap({
    required String deviceId,
    required String userId,
    required Map<String, dynamic> map,
  }) {
    return CamoDeviceRegistryModel(
      deviceId: deviceId,
      userId: userId,
      publicKey: map['publicKey'] as String? ?? '',
      platform: map['platform'] as String? ?? 'unknown',
      status: _statusFromString(map['status']),
      keyVersion: map['keyVersion'] as int? ?? 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastSeenAt: DateTime.parse(map['lastSeenAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'publicKey': publicKey,
      'platform': platform,
      'status': status.name,
      'keyVersion': keyVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'lastSeenAt': lastSeenAt.toUtc().toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static CamoDeviceStatus _statusFromString(Object? value) {
    switch (value) {
      case 'active':
        return CamoDeviceStatus.active;
      case 'revoked':
        return CamoDeviceStatus.revoked;
      case 'blocked':
        return CamoDeviceStatus.blocked;
      default:
        throw const FormatException(
          'Device status is missing, invalid, or unsupported.',
        );
    }
  }
}
