class CamoRecoveryViewState {
  const CamoRecoveryViewState.unbound()
    : encryptedBackupAvailable = false,
      providerConnected = false,
      recoveryVerified = false,
      deviceLossRecoveryAvailable = false,
      migrationAvailable = false;

  final bool encryptedBackupAvailable;
  final bool providerConnected;
  final bool recoveryVerified;
  final bool deviceLossRecoveryAvailable;
  final bool migrationAvailable;
}
