// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

// ---------------------------------------------------------------------------
// CAMO Remote Public Key Provider
// ---------------------------------------------------------------------------

/// Resolves the trusted public key used for key agreement with a remote user.
///
/// This abstraction allows CAMO to migrate public-key resolution from the
/// legacy user-profile location to the Device Registry without coupling the
/// Crypto Facade to either storage implementation.
///
/// Implementations must never expose:
///
/// - private keys
/// - shared secrets
/// - derived encryption keys
/// - plaintext or decrypted content
abstract class CamoRemotePublicKeyProvider {
  /// Returns the decoded X25519 public key for the remote identity.
  ///
  /// Throws a [StateError] when no trusted public key is available.
  Future<Uint8List> getPublicKey({
    required String remoteUserId,
  });
}
