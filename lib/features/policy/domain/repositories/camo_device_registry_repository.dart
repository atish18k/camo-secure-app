// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_device_registry_entity.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registry Repository
// ---------------------------------------------------------------------------

/// Defines trusted Device Registry operations used by CAMO.
///
/// Implementations must store and expose public device-registration metadata
/// only.
///
/// The repository must never receive, store or expose:
///
/// - private keys
/// - shared secrets
/// - derived encryption keys
/// - plaintext or decrypted content
abstract class CamoDeviceRegistryRepository {
  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  /// Returns the registered device identified by [deviceId] and owned by
  /// [userId].
  ///
  /// Returns `null` when no matching registration exists.
  Future<CamoDeviceRegistryEntity?> getDevice({
    required String userId,
    required String deviceId,
  });

  // ---------------------------------------------------------------------------
  // Get Active Device
  // ---------------------------------------------------------------------------

  /// Returns an active registered device belonging to [userId].
  ///
  /// The current implementation may select one active cryptographic device.
  /// The abstraction remains compatible with future multi-device selection,
  /// device priority and key-rotation policies.
  ///
  /// Returns `null` when no active registered device exists.
  Future<CamoDeviceRegistryEntity?> getActiveDevice({required String userId});

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  /// Creates or updates a trusted device registration.
  ///
  /// Registration must contain the device public key only.
  /// The device private key must remain inside secure local storage.
  Future<void> registerDevice(CamoDeviceRegistryEntity device);

  // ---------------------------------------------------------------------------
  // Update Last Seen
  // ---------------------------------------------------------------------------

  /// Updates device activity only after successful policy and device
  /// validation.
  Future<void> updateLastSeen({
    required String userId,
    required String deviceId,
    required DateTime lastSeenAt,
  });
}
