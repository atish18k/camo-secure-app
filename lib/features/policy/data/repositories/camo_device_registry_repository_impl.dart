// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/camo_device_registry_entity.dart';
import '../../domain/repositories/camo_device_registry_repository.dart';
import '../datasources/camo_device_registry_remote_datasource.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registry Repository Implementation
// ---------------------------------------------------------------------------

/// Enterprise implementation of the CAMO Device Registry repository.
///
/// This repository manages trusted public device-registration metadata only.
///
/// It never stores or exposes:
///
/// - private keys
/// - shared secrets
/// - derived encryption keys
/// - plaintext or decrypted content
class CamoDeviceRegistryRepositoryImpl implements CamoDeviceRegistryRepository {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoDeviceRegistryRepositoryImpl(this._remoteDataSource);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final CamoDeviceRegistryRemoteDataSource _remoteDataSource;

  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryEntity?> getDevice({
    required String userId,
    required String deviceId,
  }) {
    return _remoteDataSource.getDevice(userId: userId, deviceId: deviceId);
  }

  // ---------------------------------------------------------------------------
  // Get Active Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryEntity?> getActiveDevice({required String userId}) {
    return _remoteDataSource.getActiveDevice(userId: userId);
  }

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  @override
  Future<void> registerDevice(CamoDeviceRegistryEntity device) {
    return _remoteDataSource.registerDevice(device);
  }

  // ---------------------------------------------------------------------------
  // Update Last Seen
  // ---------------------------------------------------------------------------

  @override
  Future<void> updateLastSeen({
    required String userId,
    required String deviceId,
    required DateTime lastSeenAt,
  }) {
    return _remoteDataSource.updateLastSeen(
      userId: userId,
      deviceId: deviceId,
      lastSeenAt: lastSeenAt,
    );
  }
}
