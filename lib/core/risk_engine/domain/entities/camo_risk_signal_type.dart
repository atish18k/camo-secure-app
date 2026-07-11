// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoRiskSignalType {
  rootedDevice,
  emulatorDetected,
  debugDetected,
  tamperDetected,
  hookDetected,
  integrityFailed,
  replayAttempt,
  unusualVelocity,
  newDevice,
  networkAnomaly,
  impossibleTravel,
  repeatedAuthorizationFailure,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoRiskSignalTypeExtension on CamoRiskSignalType {
  bool get isCritical {
    return this == CamoRiskSignalType.tamperDetected ||
        this == CamoRiskSignalType.hookDetected ||
        this == CamoRiskSignalType.integrityFailed ||
        this == CamoRiskSignalType.replayAttempt;
  }
}
