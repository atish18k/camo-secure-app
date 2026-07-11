abstract interface class CamoAuthorizedWorkspaceService {
  Future<String> encode({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  });

  Future<String> decode({
    required String pairingId,
    required String encodedText,
  });
}
