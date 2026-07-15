abstract interface class CamoP256SignatureVerificationPrimitive {
  Future<bool> verify({
    required List<int> message,
    required List<int> rawSignature,
    required List<int> publicKeyX,
    required List<int> publicKeyY,
  });
}
