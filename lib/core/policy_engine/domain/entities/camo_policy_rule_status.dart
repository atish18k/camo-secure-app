// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoPolicyRuleStatus { passed, failed, notApplicable, requiresStepUp }

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoPolicyRuleStatusExtension on CamoPolicyRuleStatus {
  bool get isBlocking {
    return this == CamoPolicyRuleStatus.failed;
  }

  bool get requiresStepUp {
    return this == CamoPolicyRuleStatus.requiresStepUp;
  }
}
