// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../pairing/security/device_key_manager.dart';
import '../../domain/entities/camo_device_registry_entity.dart';
import '../../domain/repositories/camo_device_identity_service.dart';
import '../../domain/repositories/camo_device_registration_service.dart';
import '../../domain/repositories/camo_device_registry_repository.dart';
import '../../domain/repositories/camo_platform_info_provider.dart';
import '../models/camo_device_registration_request_model.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registration Service Implementation
// ---------------------------------------------------------------------------

/// Enterprise device-registration implementation.
///
/// Security guarantees:
///
/// - requires an authenticated user
/// - uses a permanent privacy-preserving installation identifier
/// - creates one local X25519 key pair when none exists
/// - uploads the public key only
/// - never overwrites blocked or revoked registrations
/// - never silently replaces a mismatched registered public key
class CamoDeviceRegistrationServiceImpl
    implements CamoDeviceRegistrationService {
  const CamoDeviceRegistrationServiceImpl(
    this._authRepository,
    this._deviceIdentityService,
    this._platformInfoProvider,
    this._deviceKeyManager,
    this._deviceRegistryRepository, [
    this._requestIdGenerator,
  ]);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final AuthRepository _authRepository;
  final CamoDeviceIdentityService _deviceIdentityService;
  final CamoPlatformInfoProvider _platformInfoProvider;
  final DeviceKeyManager _deviceKeyManager;
  final CamoDeviceRegistryRepository _deviceRegistryRepository;
  final String Function()? _requestIdGenerator;

  // ---------------------------------------------------------------------------
  // Register Current Device
  // ---------------------------------------------------------------------------

  @override
  Future<CamoDeviceRegistryEntity> registerCurrentDevice() async {
    final String? currentUserId = _authRepository.currentUserId;

    if (currentUserId == null || currentUserId.trim().isEmpty) {
      throw StateError(
        'Authenticated user is required for device registration.',
      );
    }

    final String normalizedUserId = currentUserId.trim();
    final String deviceId = (await _deviceIdentityService.getDeviceId()).trim();

    if (deviceId.isEmpty) {
      throw StateError('Trusted device identifier is unavailable.');
    }

    var keyPair = await _deviceKeyManager.loadKeyPair();

    if (keyPair == null) {
      keyPair = await _deviceKeyManager.createKeyPair();
      await _deviceKeyManager.saveKeyPair(keyPair);
    }

    if (keyPair.publicKey.isEmpty || keyPair.privateKey.isEmpty) {
      throw StateError('Generated device key pair is invalid.');
    }

    final String publicKey = base64Encode(keyPair.publicKey);

    final CamoDeviceRegistryEntity? existingDevice =
        await _deviceRegistryRepository.getDevice(
          userId: normalizedUserId,
          deviceId: deviceId,
        );

    final DateTime now = DateTime.now().toUtc();

    if (existingDevice != null) {
      _validateExistingRegistration(
        existingDevice: existingDevice,
        localPublicKey: publicKey,
      );

      await _deviceRegistryRepository.updateLastSeen(
        userId: normalizedUserId,
        deviceId: deviceId,
        lastSeenAt: now,
      );

      return CamoDeviceRegistryEntity(
        deviceId: existingDevice.deviceId,
        userId: existingDevice.userId,
        publicKey: existingDevice.publicKey,
        platform: existingDevice.platform,
        status: existingDevice.status,
        keyVersion: existingDevice.keyVersion,
        createdAt: existingDevice.createdAt,
        lastSeenAt: now,
      );
    }

    final String platform = _platformInfoProvider
        .getPlatformInfo()
        .registryValue;

    final CamoDeviceRegistryEntity newDevice = CamoDeviceRegistryEntity(
      deviceId: deviceId,
      userId: normalizedUserId,
      publicKey: publicKey,
      platform: platform,
      status: CamoDeviceStatus.active,
      keyVersion: 1,
      createdAt: now,
      lastSeenAt: now,
    );

    await _deviceRegistryRepository.registerDevice(newDevice);

    return newDevice;
  }

  @override
  Future<void> submitCurrentDeviceRegistrationRequest() async {
    final userId = _authRepository.currentUserId?.trim() ?? '';
    if (userId.isEmpty) {
      throw StateError(
        'Authenticated user is required for device registration.',
      );
    }
    final deviceId = (await _deviceIdentityService.getDeviceId()).trim();
    if (deviceId.isEmpty) {
      throw StateError('Trusted device identifier is unavailable.');
    }
    var keyPair = await _deviceKeyManager.loadKeyPair();
    if (keyPair == null) {
      keyPair = await _deviceKeyManager.createKeyPair();
      await _deviceKeyManager.saveKeyPair(keyPair);
    }
    if (keyPair.publicKey.length != 32 || keyPair.privateKey.isEmpty) {
      throw StateError('Generated device key pair is invalid.');
    }
    final publicKey = base64Encode(keyPair.publicKey);
    final existingDevice = await _deviceRegistryRepository.getDevice(
      userId: userId,
      deviceId: deviceId,
    );
    if (existingDevice != null) {
      _validateExistingRegistration(
        existingDevice: existingDevice,
        localPublicKey: publicKey,
      );
      await _deviceRegistryRepository.updateLastSeen(
        userId: userId,
        deviceId: deviceId,
        lastSeenAt: DateTime.now().toUtc(),
      );
      return;
    }
    final generator = _requestIdGenerator;
    if (generator == null) {
      throw StateError(
        'Secure registration request ID generator is unavailable.',
      );
    }
    final request = CamoDeviceRegistrationRequestModel(
      requestId: generator(),
      userId: userId,
      deviceId: deviceId,
      publicKey: publicKey,
      keyVersion: 1,
      platform: _platformInfoProvider.getPlatformInfo().registryValue,
      requestedAt: DateTime.now().toUtc(),
    );
    await _deviceRegistryRepository.submitRegistrationRequest(
      requestId: request.requestId,
      userId: request.userId,
      deviceId: request.deviceId,
      publicKey: request.publicKey,
      keyVersion: request.keyVersion,
      platform: request.platform,
      requestedAt: request.requestedAt,
    );
  }
  // ---------------------------------------------------------------------------
  // Existing Registration Validation
  // ---------------------------------------------------------------------------

  void _validateExistingRegistration({
    required CamoDeviceRegistryEntity existingDevice,
    required String localPublicKey,
  }) {
    if (existingDevice.isRevoked) {
      throw StateError('This CAMO device registration is revoked.');
    }

    if (existingDevice.isBlocked) {
      throw StateError('This CAMO device registration is blocked.');
    }

    if (!existingDevice.isActive) {
      throw StateError('This CAMO device registration is not active.');
    }

    if (existingDevice.keyVersion < 1) {
      throw StateError('Registered device key version is invalid.');
    }

    if (existingDevice.publicKey.trim() != localPublicKey) {
      throw StateError(
        'Registered device public key does not match the local device key.',
      );
    }
  }
}
