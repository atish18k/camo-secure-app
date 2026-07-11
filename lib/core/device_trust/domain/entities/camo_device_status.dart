// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoDeviceStatus { pending, approved, rejected, revoked, blacklisted }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoDeviceStatusExtension on CamoDeviceStatus {
  bool get isApproved => this == CamoDeviceStatus.approved;
  bool get isBlocked {
    return this == CamoDeviceStatus.revoked ||
        this == CamoDeviceStatus.blacklisted ||
        this == CamoDeviceStatus.rejected;
  }

  bool get requiresReview => this == CamoDeviceStatus.pending;
}
