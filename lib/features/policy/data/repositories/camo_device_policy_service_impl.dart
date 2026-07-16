// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../pairing/security/device_key_manager.dart';
import '../../domain/entities/camo_device_registry_entity.dart';
import '../../domain/repositories/camo_device_identity_service.dart';
import '../../domain/repositories/camo_device_policy_service.dart';
import '../../domain/repositories/camo_device_registry_repository.dart';

// ---------------------------------------------------------------------------
// CAMO Device Policy Service Implementation
// ---------------------------------------------------------------------------

/// Validates the current CAMO installation against the trusted Device Registry.
///
/// Security guarantees:
///
/// - requires an authenticated user
/// - requires a permanent local device identifier
/// - requires a locally secured X25519 key pair
/// - requires an active matching Firestore device registration
/// - fails closed when any trusted state is missing or invalid
/// - never exposes, uploads, or compares private keys
class CamoDevicePolicyServiceImpl implements CamoDevicePolicyService {
  const CamoDevicePolicyServiceImpl(
    this._authRepository,
    this._deviceIdentityService,
    this._deviceKeyManager,
    this._deviceRegistryRepository,
  );

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final AuthRepository _authRepository;
  final CamoDeviceIdentityService _deviceIdentityService;
  final DeviceKeyManager _deviceKeyManager;
  final CamoDeviceRegistryRepository _deviceRegistryRepository;

  // ---------------------------------------------------------------------------
  // Current Device ID
  // ---------------------------------------------------------------------------

  @override
  Future<String> getCurrentDeviceId() async {
    final String deviceId = (await _deviceIdentityService.getDeviceId()).trim();

    if (deviceId.isEmpty) {
      throw StateError('Trusted CAMO device identifier is unavailable.');
    }

    return deviceId;
  }

  // ---------------------------------------------------------------------------
  // Device Validation
  // ---------------------------------------------------------------------------

  @override
  Future<bool> isCurrentDeviceValid() async {
    final String? currentUserId = _authRepository.currentUserId;

    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return false;
    }

    final String deviceId;

    try {
      deviceId = await getCurrentDeviceId();
    } on StateError {
      return false;
    }

    final keyPair = await _deviceKeyManager.loadKeyPair();

    if (keyPair == null ||
        keyPair.publicKey.isEmpty ||
        keyPair.privateKey.isEmpty) {
      return false;
    }

    final CamoDeviceRegistryEntity? registeredDevice =
        await _deviceRegistryRepository.getDevice(
          userId: currentUserId.trim(),
          deviceId: deviceId,
        );

    if (registeredDevice == null ||
        !registeredDevice.isApproved ||
        registeredDevice.keyVersion < 1) {
      return false;
    }

    final String registeredPublicKey = registeredDevice.publicKey.trim();

    if (registeredPublicKey.isEmpty) {
      return false;
    }

    List<int> registeredPublicKeyBytes;

    try {
      registeredPublicKeyBytes = base64Decode(registeredPublicKey);
    } on FormatException {
      return false;
    }

    return _constantTimeEquals(keyPair.publicKey, registeredPublicKeyBytes);
  }

  // ---------------------------------------------------------------------------
  // Constant-Time Comparison
  // ---------------------------------------------------------------------------

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
