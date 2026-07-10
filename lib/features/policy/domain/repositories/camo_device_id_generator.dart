// ---------------------------------------------------------------------------
// CAMO Device ID Generator
// ---------------------------------------------------------------------------

/// Generates a cryptographically secure identifier for a CAMO installation.
///
/// The generated identifier:
///
/// - must be unique per installation
/// - must not use IMEI, MAC address, Android ID, or hardware serial
/// - must not expose personal or hardware information
/// - must be persisted in secure storage after generation
abstract class CamoDeviceIdGenerator {
  /// Generates a cryptographically secure UUID v4 compatible identifier.
  String generate();
}