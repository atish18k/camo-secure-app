// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoAuthorizationPipelineStatus {
  initialized,
  identityValidated,
  deviceValidated,
  riskValidated,
  commercialValidated,
  policyValidated,
  keyReleaseAuthorized,
  completed,
  denied,
  failed,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoAuthorizationPipelineStatusExtension
    on CamoAuthorizationPipelineStatus {
  bool get isTerminal {
    return this == CamoAuthorizationPipelineStatus.completed ||
        this == CamoAuthorizationPipelineStatus.denied ||
        this == CamoAuthorizationPipelineStatus.failed;
  }

  bool get isSuccessful {
    return this == CamoAuthorizationPipelineStatus.completed;
  }
}
