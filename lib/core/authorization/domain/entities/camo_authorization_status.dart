// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoAuthorizationStatus {
  requested,
  allowed,
  denied,
  stepUpRequired,
  expired,
  consumed,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoAuthorizationStatusExtension on CamoAuthorizationStatus {
  bool get isTerminal {
    return this == CamoAuthorizationStatus.denied ||
        this == CamoAuthorizationStatus.expired ||
        this == CamoAuthorizationStatus.consumed;
  }

  bool get permitsOperation {
    return this == CamoAuthorizationStatus.allowed;
  }
}
