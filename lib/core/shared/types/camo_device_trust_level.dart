// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoDeviceTrustLevel {
  unknown,
  untrusted,
  provisional,
  trusted,
  revoked,
  blacklisted,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoDeviceTrustLevelExtension on CamoDeviceTrustLevel {
  bool get permitsSensitiveOperation {
    return this == CamoDeviceTrustLevel.trusted;
  }

  bool get isBlocked {
    return this == CamoDeviceTrustLevel.revoked ||
        this == CamoDeviceTrustLevel.blacklisted;
  }
}
