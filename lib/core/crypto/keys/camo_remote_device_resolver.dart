// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../../features/policy/domain/entities/camo_device_registry_entity.dart';

// ---------------------------------------------------------------------------
// CAMO Remote Device Resolver
// ---------------------------------------------------------------------------

/// Resolves the trusted cryptographic device belonging to a remote CAMO user.
///
/// This abstraction separates remote-device selection from:
///
/// - the Crypto Facade
/// - public-key decoding
/// - Firestore implementation details
/// - legacy profile-based key storage
///
/// Implementations must:
///
/// - resolve active trusted device registrations only
/// - reject blocked or revoked devices
/// - remain compatible with future multi-device selection policies
/// - never expose private keys, shared secrets or derived encryption keys
abstract class CamoRemoteDeviceResolver {
  /// Resolves the trusted device selected for cryptographic communication with
  /// [remoteUserId].
  ///
  /// Throws a [StateError] when no trusted active crypto device is available.
  Future<CamoDeviceRegistryEntity> resolveDevice({
    required String remoteUserId,
  });
}
