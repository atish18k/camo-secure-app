// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoSecuritySessionStatus {
  created,
  active,
  stepUpRequired,
  suspended,
  consumed,
  expired,
  revoked,
  terminated,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoSecuritySessionStatusExtension on CamoSecuritySessionStatus {
  bool get isActive {
    return this == CamoSecuritySessionStatus.active;
  }

  bool get isTerminal {
    return this == CamoSecuritySessionStatus.consumed ||
        this == CamoSecuritySessionStatus.expired ||
        this == CamoSecuritySessionStatus.revoked ||
        this == CamoSecuritySessionStatus.terminated;
  }

  bool get requiresStepUp {
    return this == CamoSecuritySessionStatus.stepUpRequired;
  }
}
