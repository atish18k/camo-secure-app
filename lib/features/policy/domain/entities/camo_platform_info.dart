// ---------------------------------------------------------------------------
// CAMO Platform Type
// ---------------------------------------------------------------------------

/// Supported CAMO runtime platforms.
///
/// Hardware identifiers, serial numbers, IMEI values, MAC addresses and other
/// privacy-sensitive identifiers must never be added here.
enum CamoPlatformType {
  android,
  ios,
  windows,
  linux,
  macos,
  web,
  fuchsia,
  unknown,
}

// ---------------------------------------------------------------------------
// CAMO Platform Info
// ---------------------------------------------------------------------------

/// Privacy-preserving platform information for the current CAMO installation.
///
/// This entity intentionally contains only the minimum information currently
/// required by Device Registration.
///
/// Platform version, application version and user-visible device name may be
/// added later through separately approved providers. Placeholder or fabricated
/// values must never be used.
class CamoPlatformInfo {
  const CamoPlatformInfo({
    required this.type,
  });

  final CamoPlatformType type;

  String get registryValue {
    return switch (type) {
      CamoPlatformType.android => 'android',
      CamoPlatformType.ios => 'ios',
      CamoPlatformType.windows => 'windows',
      CamoPlatformType.linux => 'linux',
      CamoPlatformType.macos => 'macos',
      CamoPlatformType.web => 'web',
      CamoPlatformType.fuchsia => 'fuchsia',
      CamoPlatformType.unknown => 'unknown',
    };
  }
}
