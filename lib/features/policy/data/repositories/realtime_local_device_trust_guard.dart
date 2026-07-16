// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';

import '../../../../core/crypto/trust/camo_local_device_trust_guard.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../pairing/security/device_key_manager.dart';
import '../../domain/entities/camo_device_registry_entity.dart';
import '../../domain/repositories/camo_device_identity_service.dart';
import '../datasources/camo_device_registry_remote_datasource.dart';

// ---------------------------------------------------------------------------
// Realtime Local Device Trust Guard
// ---------------------------------------------------------------------------

/// Realtime, memory-backed local-device authorization guard.
///
/// The Firestore listener performs the remote synchronization. Crypto
/// operations validate the latest in-memory trust state and therefore do not
/// perform a separate Firestore read before every encode or decode.
class RealtimeLocalDeviceTrustGuard implements CamoLocalDeviceTrustGuard {
  RealtimeLocalDeviceTrustGuard(
    this._authRepository,
    this._deviceIdentityService,
    this._deviceKeyManager,
    this._deviceRegistryRemoteDataSource,
  );

  final AuthRepository _authRepository;
  final CamoDeviceIdentityService _deviceIdentityService;
  final DeviceKeyManager _deviceKeyManager;
  final CamoDeviceRegistryRemoteDataSource _deviceRegistryRemoteDataSource;

  StreamSubscription<CamoDeviceRegistryEntity?>? _subscription;
  Completer<void>? _initialStateCompleter;

  CamoDeviceRegistryEntity? _cachedDevice;
  Object? _streamError;

  String? _monitoredUserId;
  String? _monitoredDeviceId;

  // ---------------------------------------------------------------------------
  // Ensure Trusted
  // ---------------------------------------------------------------------------

  @override
  Future<void> ensureTrusted() async {
    final String? userIdValue = _authRepository.currentUserId;
    final String userId = userIdValue?.trim() ?? '';

    if (userId.isEmpty) {
      throw StateError(
        'Authenticated user is required for cryptographic operations.',
      );
    }

    final String deviceId = (await _deviceIdentityService.getDeviceId()).trim();

    if (deviceId.isEmpty) {
      throw StateError('Trusted local device identifier is unavailable.');
    }

    await _ensureMonitoring(userId: userId, deviceId: deviceId);

    final Completer<void>? initialStateCompleter = _initialStateCompleter;

    if (initialStateCompleter != null && !initialStateCompleter.isCompleted) {
      await initialStateCompleter.future;
    }

    final Object? streamError = _streamError;

    if (streamError != null) {
      throw StateError(
        'Local device trust synchronization failed: $streamError',
      );
    }

    final CamoDeviceRegistryEntity? device = _cachedDevice;

    if (device == null) {
      throw StateError(
        'Current device is not registered as a trusted CAMO device.',
      );
    }

    if (device.userId.trim() != userId || device.deviceId.trim() != deviceId) {
      throw StateError('Current device registration identity is invalid.');
    }

    if (!device.isApproved) {
      throw StateError('Current CAMO device is blocked or revoked.');
    }

    if (device.keyVersion < 1) {
      throw StateError('Current device key version is invalid.');
    }

    await _validateLocalPublicKey(device);
  }

  // ---------------------------------------------------------------------------
  // Realtime Monitoring
  // ---------------------------------------------------------------------------

  Future<void> _ensureMonitoring({
    required String userId,
    required String deviceId,
  }) async {
    if (_subscription != null &&
        _monitoredUserId == userId &&
        _monitoredDeviceId == deviceId) {
      return;
    }

    await _subscription?.cancel();

    _cachedDevice = null;
    _streamError = null;
    _monitoredUserId = userId;
    _monitoredDeviceId = deviceId;
    _initialStateCompleter = Completer<void>();

    _subscription = _deviceRegistryRemoteDataSource
        .watchDevice(userId: userId, deviceId: deviceId)
        .listen(
          (CamoDeviceRegistryEntity? device) {
            _cachedDevice = device;
            _streamError = null;
            _completeInitialState();
          },
          onError: (Object error, StackTrace stackTrace) {
            _cachedDevice = null;
            _streamError = error;

            final Completer<void>? completer = _initialStateCompleter;

            if (completer != null && !completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          },
        );
  }

  void _completeInitialState() {
    final Completer<void>? completer = _initialStateCompleter;

    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  // ---------------------------------------------------------------------------
  // Cryptographic Binding
  // ---------------------------------------------------------------------------

  Future<void> _validateLocalPublicKey(CamoDeviceRegistryEntity device) async {
    final keyPair = await _deviceKeyManager.loadKeyPair();

    if (keyPair == null ||
        keyPair.privateKey.isEmpty ||
        keyPair.publicKey.isEmpty) {
      throw StateError('Local device key pair is unavailable.');
    }

    final String encodedRegisteredKey = device.publicKey.trim();

    if (encodedRegisteredKey.isEmpty) {
      throw StateError('Registered device public key is unavailable.');
    }

    final List<int> registeredPublicKey;

    try {
      registeredPublicKey = base64Decode(encodedRegisteredKey);
    } on FormatException {
      throw StateError('Registered device public key has invalid encoding.');
    }

    if (!_constantTimeEquals(keyPair.publicKey, registeredPublicKey)) {
      throw StateError(
        'Local key pair does not match the trusted device registration.',
      );
    }
  }

  bool _constantTimeEquals(List<int> first, List<int> second) {
    if (first.length != second.length) {
      return false;
    }

    int difference = 0;

    for (int index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }

    return difference == 0;
  }
}
