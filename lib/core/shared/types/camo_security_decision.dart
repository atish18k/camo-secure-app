// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoSecurityDecision { allow, deny, stepUpRequired }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoSecurityDecisionExtension on CamoSecurityDecision {
  bool get isAllowed => this == CamoSecurityDecision.allow;
  bool get isDenied => this == CamoSecurityDecision.deny;
  bool get requiresStepUp => this == CamoSecurityDecision.stepUpRequired;
}
