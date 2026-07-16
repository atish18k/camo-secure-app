import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/device_trust/domain/entities/camo_device_status.dart';
import '../../domain/entities/camo_device_registry_entity.dart';

/// Strict parser for the canonical server-owned device document.
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

  factory CamoDeviceRegistryModel.fromMap({
    required String deviceId,
    required String userId,
    required Map<String, dynamic> map,
  }) {
    if (map['schemaVersion'] != 1) {
      throw const FormatException('Unsupported device schema version.');
    }
    final mappedDeviceId = _requiredString(map, 'deviceId');
    final mappedUserId = _requiredString(map, 'userId');
    if (mappedDeviceId != deviceId || mappedUserId != userId) {
      throw const FormatException(
        'Device document identity binding is invalid.',
      );
    }
    final keyVersion = map['keyVersion'];
    if (keyVersion is! int || keyVersion < 1) {
      throw const FormatException('Device key version is invalid.');
    }
    final approved = map['approved'];
    final revoked = map['revoked'];
    if (approved is! bool || revoked is! bool) {
      throw const FormatException('Device approval flags are invalid.');
    }
    final status = _statusFromString(map['status']);
    if ((status == CamoDeviceStatus.approved) != approved) {
      throw const FormatException(
        'Device approved flag does not match status.',
      );
    }
    if ((status == CamoDeviceStatus.revoked) != revoked) {
      throw const FormatException('Device revoked flag does not match status.');
    }
    return CamoDeviceRegistryModel(
      deviceId: deviceId,
      userId: userId,
      publicKey: _requiredString(map, 'publicKey'),
      platform: _requiredString(map, 'platform'),
      status: status,
      keyVersion: keyVersion,
      createdAt: _requiredTimestamp(map, 'createdAt'),
      lastSeenAt: _requiredTimestamp(map, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'schemaVersion': 1,
    'deviceId': deviceId,
    'userId': userId,
    'publicKey': publicKey,
    'platform': platform,
    'status': status.name,
    'keyVersion': keyVersion,
    'approved': status == CamoDeviceStatus.approved,
    'revoked': status == CamoDeviceStatus.revoked,
    'createdAt': Timestamp.fromDate(createdAt.toUtc()),
    'updatedAt': Timestamp.fromDate(lastSeenAt.toUtc()),
  };

  static String _requiredString(Map<String, dynamic> map, String field) {
    final value = map[field];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Device $field is missing or invalid.');
    }
    return value.trim();
  }

  static DateTime _requiredTimestamp(Map<String, dynamic> map, String field) {
    final value = map[field];
    if (value is! Timestamp) {
      throw FormatException('Device $field must be a Firestore Timestamp.');
    }
    return value.toDate().toUtc();
  }

  static CamoDeviceStatus _statusFromString(Object? value) {
    switch (value) {
      case 'pending':
        return CamoDeviceStatus.pending;
      case 'approved':
        return CamoDeviceStatus.approved;
      case 'rejected':
        return CamoDeviceStatus.rejected;
      case 'revoked':
        return CamoDeviceStatus.revoked;
      case 'blacklisted':
        return CamoDeviceStatus.blacklisted;
      default:
        throw const FormatException(
          'Device status is missing, invalid, or unsupported.',
        );
    }
  }
}
