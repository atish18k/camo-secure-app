// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_platform_info.dart';

// ---------------------------------------------------------------------------
// CAMO Platform Info Provider
// ---------------------------------------------------------------------------

/// Supplies privacy-preserving information about the current runtime platform.
///
/// Implementations must not collect or expose:
///
/// - IMEI
/// - MAC address
/// - hardware serial number
/// - advertising identifier
/// - Android ID
/// - personal information
abstract class CamoPlatformInfoProvider {
  CamoPlatformInfo getPlatformInfo();
}
