// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoSubscriptionStatus {
  unknown,
  trial,
  active,
  gracePeriod,
  paused,
  expired,
  cancelled,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoSubscriptionStatusExtension on CamoSubscriptionStatus {
  bool get permitsBaseAccess {
    return this == CamoSubscriptionStatus.trial ||
        this == CamoSubscriptionStatus.active ||
        this == CamoSubscriptionStatus.gracePeriod;
  }

  bool get requiresRenewal {
    return this == CamoSubscriptionStatus.expired ||
        this == CamoSubscriptionStatus.cancelled;
  }
}
