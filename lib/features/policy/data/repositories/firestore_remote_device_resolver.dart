// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../../../core/crypto/keys/camo_remote_device_resolver.dart';
import '../../domain/entities/camo_device_registry_entity.dart';
import '../datasources/camo_device_registry_remote_datasource.dart';

// ---------------------------------------------------------------------------
// Firestore Remote Device Resolver
// ---------------------------------------------------------------------------

/// Realtime, memory-backed remote-device resolver.
///
/// One Firestore listener is maintained per resolved remote user. Normal
/// encode/decode operations read the latest trust state from memory and do not
/// execute a separate Firestore query for every operation.
///
/// The resolver fails closed when:
///
/// - no active remote device exists
/// - synchronization fails
/// - the resolved device belongs to another user
/// - trusted public-key metadata is invalid
class FirestoreRemoteDeviceResolver implements CamoRemoteDeviceResolver {
  FirestoreRemoteDeviceResolver(this._remoteDataSource);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final CamoDeviceRegistryRemoteDataSource _remoteDataSource;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  final Map<String, _RemoteDeviceMonitor> _monitors =
      <String, _RemoteDeviceMonitor>{};

  // ---------------------------------------------------------------------------
  // Resolve Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryEntity> resolveDevice({
    required String remoteUserId,
  }) async {
    final String normalizedUserId = remoteUserId.trim();

    if (normalizedUserId.isEmpty) {
      throw StateError('Remote user identifier is required.');
    }

    final _RemoteDeviceMonitor monitor = _monitors.putIfAbsent(
      normalizedUserId,
      () => _createMonitor(normalizedUserId),
    );

    await monitor.waitForInitialState();

    final Object? synchronizationError = monitor.synchronizationError;

    if (synchronizationError != null) {
      throw StateError(
        'Remote device trust synchronization failed: '
        '$synchronizationError',
      );
    }

    final CamoDeviceRegistryEntity? device = monitor.device;

    if (device == null) {
      throw StateError(
        'No active trusted device is registered for the remote user.',
      );
    }

    _validateResolvedDevice(device: device, remoteUserId: normalizedUserId);

    return device;
  }

  // ---------------------------------------------------------------------------
  // Monitoring
  // ---------------------------------------------------------------------------

  _RemoteDeviceMonitor _createMonitor(String remoteUserId) {
    final _RemoteDeviceMonitor monitor = _RemoteDeviceMonitor();

    monitor.subscription = _remoteDataSource
        .watchActiveDevice(userId: remoteUserId)
        .listen(
          (CamoDeviceRegistryEntity? device) {
            monitor.device = device;
            monitor.synchronizationError = null;
            monitor.completeInitialState();
          },
          onError: (Object error, StackTrace stackTrace) {
            monitor.device = null;
            monitor.synchronizationError = error;
            monitor.completeInitialStateWithError(error, stackTrace);
          },
        );

    return monitor;
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  void _validateResolvedDevice({
    required CamoDeviceRegistryEntity device,
    required String remoteUserId,
  }) {
    if (device.userId.trim() != remoteUserId) {
      throw StateError(
        'Resolved device does not belong to the requested remote user.',
      );
    }

    if (!device.isActive) {
      throw StateError('Resolved remote device is not active.');
    }

    if (device.deviceId.trim().isEmpty) {
      throw StateError('Resolved remote device identifier is invalid.');
    }

    if (device.publicKey.trim().isEmpty) {
      throw StateError('Resolved remote device public key is unavailable.');
    }

    if (device.keyVersion < 1) {
      throw StateError('Resolved remote device key version is invalid.');
    }
  }
}

// ---------------------------------------------------------------------------
// Remote Device Monitor
// ---------------------------------------------------------------------------

class _RemoteDeviceMonitor {
  final Completer<void> _initialStateCompleter = Completer<void>();

  StreamSubscription<CamoDeviceRegistryEntity?>? subscription;

  CamoDeviceRegistryEntity? device;

  Object? synchronizationError;

  Future<void> waitForInitialState() {
    return _initialStateCompleter.future;
  }

  void completeInitialState() {
    if (!_initialStateCompleter.isCompleted) {
      _initialStateCompleter.complete();
    }
  }

  void completeInitialStateWithError(Object error, StackTrace stackTrace) {
    if (!_initialStateCompleter.isCompleted) {
      _initialStateCompleter.completeError(error, stackTrace);
    }
  }
}
