// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoEnterpriseOperationStage {
  initialized,
  requestValidated,
  authorizationRequested,
  authorizationGranted,
  keyReleaseGranted,
  executionAuthorized,
  executionCompleted,
  authorizationConsumed,
  completed,
  denied,
  failed,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoEnterpriseOperationStageExtension
    on CamoEnterpriseOperationStage {
  bool get isTerminal {
    return this == CamoEnterpriseOperationStage.completed ||
        this == CamoEnterpriseOperationStage.denied ||
        this == CamoEnterpriseOperationStage.failed;
  }

  bool get isSuccessful {
    return this == CamoEnterpriseOperationStage.completed;
  }
}
