// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoOperationStage {
  requestValidated,
  authorizationGranted,
  readyForExecution,
  authorizationConsumed,
  denied,
  failed,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoOperationStageExtension on CamoOperationStage {
  bool get permitsExecution => this == CamoOperationStage.readyForExecution;
  bool get isTerminal {
    return this == CamoOperationStage.authorizationConsumed ||
        this == CamoOperationStage.denied ||
        this == CamoOperationStage.failed;
  }
}
