// ---------------------------------------------------------------------------
// CAMO License Policy Service
// ---------------------------------------------------------------------------

/// Provides verified license state to the CAMO Policy Engine.
///
/// Implementations must obtain license information from trusted local or
/// server-side sources.
///
/// This service must never use hard-coded values to allow protected
/// operations.
abstract class CamoLicensePolicyService {
  /// Returns whether the authenticated user's CAMO license is currently valid.
  Future<bool> isLicenseValid();
}