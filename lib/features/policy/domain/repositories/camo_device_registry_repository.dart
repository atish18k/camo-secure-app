// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_device_registry_entity.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registry Repository
// ---------------------------------------------------------------------------

/// Defines the trusted device-registry operations used by CAMO.
///
/// Implementations must store device registration metadata only.
///
/// The repository must never receive, store, or expose:
///
/// - private keys
/// - shared secrets
/// - derived encryption keys
/// - plaintext or decrypted content
abstract class CamoDeviceRegistryRepository {
  // ---------------------------------------------------------------------------
  // Get Device
  // ---------------------------------------------------------------------------

  /// Returns the registered device belonging to [userId].
  ///
  /// Returns `null` when no matching registration exists.
  Future<CamoDeviceRegistryEntity?> getDevice({
    required String userId,
    required String deviceId,
  });

  // ---------------------------------------------------------------------------
  // Register Device
  // ---------------------------------------------------------------------------

  /// Creates or updates a trusted device registration.
  ///
  /// Registration must contain the device public key only.
  /// The device private key must remain inside secure local storage.
  Future<void> registerDevice(
    CamoDeviceRegistryEntity device,
  );

  // ---------------------------------------------------------------------------
  // Update Last Seen
  // ---------------------------------------------------------------------------

  /// Updates the device activity timestamp only after successful policy and
  /// device validation.
  Future<void> updateLastSeen({
    required String userId,
    required String deviceId,
    required DateTime lastSeenAt,
  });
}
