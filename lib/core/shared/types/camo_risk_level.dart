// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoRiskLevel { low, medium, high, critical }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoRiskLevelExtension on CamoRiskLevel {
  bool get blocksSensitiveOperation {
    return this == CamoRiskLevel.high || this == CamoRiskLevel.critical;
  }

  int get severity {
    return switch (this) {
      CamoRiskLevel.low => 1,
      CamoRiskLevel.medium => 2,
      CamoRiskLevel.high => 3,
      CamoRiskLevel.critical => 4,
    };
  }
}
