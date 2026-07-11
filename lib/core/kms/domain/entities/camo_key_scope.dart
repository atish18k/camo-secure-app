// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoKeyScope { operation, message, device, pair, tenant }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoKeyScopeExtension on CamoKeyScope {
  bool get isShortLived {
    return this == CamoKeyScope.operation || this == CamoKeyScope.message;
  }
}
