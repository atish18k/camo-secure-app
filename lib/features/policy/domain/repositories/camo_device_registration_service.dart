// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_device_registry_entity.dart';

// ---------------------------------------------------------------------------
// CAMO Device Registration Service
// ---------------------------------------------------------------------------

/// Registers and maintains the cryptographic identity of the current CAMO
/// installation.
///
/// Implementations must register public device metadata only.
///
/// Private keys, shared secrets, derived encryption keys, plaintext and
/// decrypted content must never leave the local trusted environment.
abstract class CamoDeviceRegistrationService {
  /// Registers the current authenticated device or securely refreshes its
  /// last-seen timestamp when the existing registration is still valid.
  ///
  /// A revoked, blocked or cryptographically mismatched registration must
  /// fail closed and must never be silently overwritten.
  Future<CamoDeviceRegistryEntity> registerCurrentDevice();

  /// Submits only client-owned facts for server-side device approval.
  Future<void> submitCurrentDeviceRegistrationRequest();
}
