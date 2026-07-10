// ---------------------------------------------------------------------------
// CAMO Device Policy Service
// ---------------------------------------------------------------------------

/// Provides verified device-binding state to the CAMO Policy Engine.
///
/// Implementations must use trusted device-security and device-binding
/// infrastructure.
///
/// This service must never receive or expose:
///
/// - plaintext
/// - decrypted content
/// - encryption keys
/// - private keys
abstract class CamoDevicePolicyService {
  /// Returns the identifier of the currently bound device.
  ///
  /// Throws a [StateError] when no trusted device binding exists.
  Future<String> getCurrentDeviceId();

  /// Returns whether the current device is valid for the authenticated user.
  ///
  /// This validation must use trusted device-binding state and must not rely
  /// on hard-coded or assumed values.
  Future<bool> isCurrentDeviceValid();
}