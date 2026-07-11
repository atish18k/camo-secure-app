abstract interface class CamoWorkspaceMessageContextResolver {
  Future<String> resolveMessageId({
    required String pairingId,
    required String operationId,
  });
}
