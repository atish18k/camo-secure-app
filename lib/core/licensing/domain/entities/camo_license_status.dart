// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoLicenseStatus { unknown, pending, active, suspended, expired, revoked }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoLicenseStatusExtension on CamoLicenseStatus {
  bool get isValid {
    return this == CamoLicenseStatus.active;
  }

  bool get isBlocked {
    return this == CamoLicenseStatus.suspended ||
        this == CamoLicenseStatus.expired ||
        this == CamoLicenseStatus.revoked;
  }
}
