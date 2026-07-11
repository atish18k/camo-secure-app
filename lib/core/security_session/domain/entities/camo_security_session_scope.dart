// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoSecuritySessionScope {
  authentication,
  authorization,
  operation,
  message,
  device,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoSecuritySessionScopeExtension on CamoSecuritySessionScope {
  bool get isOperationBound {
    return this == CamoSecuritySessionScope.operation ||
        this == CamoSecuritySessionScope.message;
  }
}
