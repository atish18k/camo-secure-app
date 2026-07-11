// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoAuditSeverity { info, low, medium, high, critical }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoAuditSeverityExtension on CamoAuditSeverity {
  bool get requiresImmediateAttention {
    return this == CamoAuditSeverity.high || this == CamoAuditSeverity.critical;
  }
}
