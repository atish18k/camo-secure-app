// ---------------------------------------------------------------------------
// CAMO Device Identity Service
// ---------------------------------------------------------------------------

/// Provides the permanent identity of the current CAMO installation.
///
/// Responsibilities:
///
/// - generate the device identifier once
/// - securely persist the identifier
/// - always return the same identifier afterwards
///
/// The identifier:
///
/// - must never be derived from hardware identifiers
/// - must never contain personal information
/// - must never change during normal application usage
abstract class CamoDeviceIdentityService {
  /// Returns the permanent device identifier.
  ///
  /// If it does not yet exist, the implementation must securely generate,
  /// persist and return it.
  Future<String> getDeviceId();

  /// Removes the stored identifier.
  ///
  /// This is intended for controlled reset or testing scenarios only.
  Future<void> deleteDeviceId();
}