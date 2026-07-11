// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoKeyStatus {
  pending,
  active,
  suspended,
  rotated,
  revoked,
  expired,
  destroyed,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoKeyStatusExtension on CamoKeyStatus {
  bool get isUsable {
    return this == CamoKeyStatus.active;
  }

  bool get isTerminal {
    return this == CamoKeyStatus.revoked ||
        this == CamoKeyStatus.expired ||
        this == CamoKeyStatus.destroyed;
  }
}
