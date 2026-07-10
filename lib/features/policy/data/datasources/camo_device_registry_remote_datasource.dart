// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/camo_device_registry_entity.dart';
import '../models/camo_device_registry_model.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registry Remote Data Source
// ---------------------------------------------------------------------------

abstract class CamoDeviceRegistryRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  Future<CamoDeviceRegistryModel> getDevice({
    required String userId,
    required String deviceId,
  });

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  Future<void> registerDevice(
    CamoDeviceRegistryEntity device,
  );

  // ---------------------------------------------------------------------------
  // Update Last Seen
  // ---------------------------------------------------------------------------

  Future<void> updateLastSeen({
    required String userId,
    required String deviceId,
    required DateTime lastSeenAt,
  });
}

// ---------------------------------------------------------------------------
// Firebase CAMO Device Registry Remote Data Source
// ---------------------------------------------------------------------------

class FirebaseCamoDeviceRegistryRemoteDataSource
    implements CamoDeviceRegistryRemoteDataSource {
  const FirebaseCamoDeviceRegistryRemoteDataSource(
    this._firestore,
  );

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryModel> getDevice({
    required String userId,
    required String deviceId,
  }) async {
    final String normalizedUserId = userId.trim();
    final String normalizedDeviceId = deviceId.trim();

    if (normalizedUserId.isEmpty) {
      throw StateError('User identifier is required.');
    }

    if (normalizedDeviceId.isEmpty) {
      throw StateError('Device identifier is required.');
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _deviceDocument(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    ).get();

    final Map<String, dynamic>? data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw StateError('Registered device not found.');
    }

    return CamoDeviceRegistryModel.fromMap(
      deviceId: snapshot.id,
      userId: normalizedUserId,
      map: data,
    );
  }

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  @override
  Future<void> registerDevice(
    CamoDeviceRegistryEntity device,
  ) async {
    final String normalizedUserId = device.userId.trim();
    final String normalizedDeviceId = device.deviceId.trim();

    if (normalizedUserId.isEmpty) {
      throw StateError('User identifier is required.');
    }

    if (normalizedDeviceId.isEmpty) {
      throw StateError('Device identifier is required.');
    }

    if (device.publicKey.trim().isEmpty) {
      throw StateError('Device public key is required.');
    }

    if (device.keyVersion < 1) {
      throw StateError('Device key version must be positive.');
    }

    final CamoDeviceRegistryModel model =
        CamoDeviceRegistryModel(
      deviceId: normalizedDeviceId,
      userId: normalizedUserId,
      publicKey: device.publicKey.trim(),
      platform: device.platform.trim().isEmpty
          ? 'unknown'
          : device.platform.trim(),
      status: device.status,
      keyVersion: device.keyVersion,
      createdAt: device.createdAt.toUtc(),
      lastSeenAt: device.lastSeenAt.toUtc(),
    );

    await _deviceDocument(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    ).set(
      model.toMap(),
      SetOptions(merge: false),
    );
  }

  // ---------------------------------------------------------------------------
  // Update Last Seen
  // ---------------------------------------------------------------------------

  @override
  Future<void> updateLastSeen({
    required String userId,
    required String deviceId,
    required DateTime lastSeenAt,
  }) async {
    final String normalizedUserId = userId.trim();
    final String normalizedDeviceId = deviceId.trim();

    if (normalizedUserId.isEmpty) {
      throw StateError('User identifier is required.');
    }

    if (normalizedDeviceId.isEmpty) {
      throw StateError('Device identifier is required.');
    }

    final DocumentReference<Map<String, dynamic>> reference =
        _deviceDocument(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    );

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await reference.get();

    if (!snapshot.exists) {
      throw StateError('Registered device not found.');
    }

    await reference.update(
      <String, dynamic>{
        'lastSeenAt': lastSeenAt.toUtc().toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> _deviceDocument({
    required String userId,
    required String deviceId,
  }) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(userId)
        .collection(FirestorePaths.devices)
        .doc(deviceId);
  }
}
