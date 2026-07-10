// ---------------------------------------------------------------------------
// CAMO Local Device Trust Guard
// ---------------------------------------------------------------------------

/// Enforces trusted-device authorization before local cryptographic operations.
///
/// Implementations must fail closed when the current device is:
///
/// - missing
/// - blocked
/// - revoked
/// - cryptographically mismatched
///
/// Implementations must not expose private keys, shared secrets, derived keys,
/// plaintext or decrypted content.
abstract class CamoLocalDeviceTrustGuard {
  /// Throws a [StateError] when the current device is not trusted.
  Future<void> ensureTrusted();
}
