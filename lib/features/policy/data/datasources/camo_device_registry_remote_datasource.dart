// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/camo_device_registry_entity.dart';
import '../models/camo_device_registry_model.dart';
import '../models/camo_device_registration_request_model.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registry Remote Data Source
// ---------------------------------------------------------------------------

abstract class CamoDeviceRegistryRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  Future<CamoDeviceRegistryModel?> getDevice({
    required String userId,
    required String deviceId,
  });

  // ---------------------------------------------------------------------------
  // Get Active Device
  // ---------------------------------------------------------------------------

  Future<CamoDeviceRegistryModel?> getActiveDevice({required String userId});

  // ---------------------------------------------------------------------------
  // Watch Device
  // ---------------------------------------------------------------------------

  Stream<CamoDeviceRegistryModel?> watchDevice({
    required String userId,
    required String deviceId,
  });

  // ---------------------------------------------------------------------------
  // Watch Active Device
  // ---------------------------------------------------------------------------

  /// Watches the currently selected active crypto device for [userId].
  ///
  /// Emits `null` when no active device exists. The query remains limited to
  /// one device and is compatible with the current single-active-device phase.
  Stream<CamoDeviceRegistryModel?> watchActiveDevice({required String userId});

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  Future<void> registerDevice(CamoDeviceRegistryEntity device);

  Future<void> submitRegistrationRequest(
    CamoDeviceRegistrationRequestModel request,
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
  const FirebaseCamoDeviceRegistryRemoteDataSource(this._firestore);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryModel?> getDevice({
    required String userId,
    required String deviceId,
  }) async {
    final String normalizedUserId = userId.trim();
    final String normalizedDeviceId = deviceId.trim();

    _validateIdentifiers(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    );

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _deviceDocument(
          userId: normalizedUserId,
          deviceId: normalizedDeviceId,
        ).get();

    return _mapDocumentSnapshot(snapshot: snapshot, userId: normalizedUserId);
  }

  // ---------------------------------------------------------------------------
  // Get Active Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryModel?> getActiveDevice({
    required String userId,
  }) async {
    final String normalizedUserId = _normalizeUserId(userId);

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _activeDeviceQuery(userId: normalizedUserId).get();

    return _mapActiveQuerySnapshot(
      snapshot: snapshot,
      userId: normalizedUserId,
    );
  }

  // ---------------------------------------------------------------------------
  // Watch Device
  // ---------------------------------------------------------------------------

  @override
  Stream<CamoDeviceRegistryModel?> watchDevice({
    required String userId,
    required String deviceId,
  }) {
    final String normalizedUserId = userId.trim();
    final String normalizedDeviceId = deviceId.trim();

    _validateIdentifiers(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    );

    return _deviceDocument(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    ).snapshots().map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      return _mapDocumentSnapshot(snapshot: snapshot, userId: normalizedUserId);
    });
  }

  // ---------------------------------------------------------------------------
  // Watch Active Device
  // ---------------------------------------------------------------------------

  @override
  Stream<CamoDeviceRegistryModel?> watchActiveDevice({required String userId}) {
    final String normalizedUserId = _normalizeUserId(userId);

    return _activeDeviceQuery(userId: normalizedUserId).snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      return _mapActiveQuerySnapshot(
        snapshot: snapshot,
        userId: normalizedUserId,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  @override
  Future<void> registerDevice(CamoDeviceRegistryEntity device) async {
    final String normalizedUserId = device.userId.trim();
    final String normalizedDeviceId = device.deviceId.trim();

    _validateIdentifiers(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    );

    if (device.publicKey.trim().isEmpty) {
      throw StateError('Device public key is required.');
    }

    if (device.keyVersion < 1) {
      throw StateError('Device key version must be positive.');
    }

    final CamoDeviceRegistryModel model = CamoDeviceRegistryModel(
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
    ).set(model.toMap(), SetOptions(merge: false));
  }

  @override
  Future<void> submitRegistrationRequest(
    CamoDeviceRegistrationRequestModel request,
  ) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(request.userId)
        .collection('deviceRegistrationRequests')
        .doc(request.requestId)
        .set(request.toMap(), SetOptions(merge: false));
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

    _validateIdentifiers(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    );

    final DocumentReference<Map<String, dynamic>> reference = _deviceDocument(
      userId: normalizedUserId,
      deviceId: normalizedDeviceId,
    );

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await reference
        .get();

    if (!snapshot.exists) {
      throw StateError('Registered device not found.');
    }

    await reference.update(<String, dynamic>{
      'lastSeenAt': lastSeenAt.toUtc().toIso8601String(),
    });
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String _normalizeUserId(String userId) {
    final String normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      throw StateError('User identifier is required.');
    }

    return normalizedUserId;
  }

  void _validateIdentifiers({
    required String userId,
    required String deviceId,
  }) {
    if (userId.isEmpty) {
      throw StateError('User identifier is required.');
    }

    if (deviceId.isEmpty) {
      throw StateError('Device identifier is required.');
    }
  }

  // ---------------------------------------------------------------------------
  // Mapping
  // ---------------------------------------------------------------------------

  CamoDeviceRegistryModel? _mapDocumentSnapshot({
    required DocumentSnapshot<Map<String, dynamic>> snapshot,
    required String userId,
  }) {
    final Map<String, dynamic>? data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return CamoDeviceRegistryModel.fromMap(
      deviceId: snapshot.id,
      userId: userId,
      map: data,
    );
  }

  CamoDeviceRegistryModel? _mapActiveQuerySnapshot({
    required QuerySnapshot<Map<String, dynamic>> snapshot,
    required String userId,
  }) {
    if (snapshot.docs.isEmpty) {
      return null;
    }

    final QueryDocumentSnapshot<Map<String, dynamic>> document =
        snapshot.docs.first;

    return CamoDeviceRegistryModel.fromMap(
      deviceId: document.id,
      userId: userId,
      map: document.data(),
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore References
  // ---------------------------------------------------------------------------

  Query<Map<String, dynamic>> _activeDeviceQuery({required String userId}) {
    return _deviceCollection(
      userId: userId,
    ).where('status', isEqualTo: CamoDeviceStatus.active.name).limit(1);
  }

  CollectionReference<Map<String, dynamic>> _deviceCollection({
    required String userId,
  }) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(userId)
        .collection(FirestorePaths.devices);
  }

  DocumentReference<Map<String, dynamic>> _deviceDocument({
    required String userId,
    required String deviceId,
  }) {
    return _deviceCollection(userId: userId).doc(deviceId);
  }
}
