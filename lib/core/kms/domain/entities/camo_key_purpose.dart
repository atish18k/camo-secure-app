// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoKeyPurpose {
  messageEncryption,
  messageDecryption,
  keyWrapping,
  keyUnwrapping,
  deviceBinding,
  authorizationProof,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoKeyPurposeExtension on CamoKeyPurpose {
  String get wireName {
    return switch (this) {
      CamoKeyPurpose.messageEncryption => 'message_encryption',
      CamoKeyPurpose.messageDecryption => 'message_decryption',
      CamoKeyPurpose.keyWrapping => 'key_wrapping',
      CamoKeyPurpose.keyUnwrapping => 'key_unwrapping',
      CamoKeyPurpose.deviceBinding => 'device_binding',
      CamoKeyPurpose.authorizationProof => 'authorization_proof',
    };
  }
}
