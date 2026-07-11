// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoOperationType {
  encode,
  decode,
  pair,
  unpair,
  registerDevice,
  approveDevice,
  revokeDevice,
  validateSession,
  validateLicense,
  validateEntitlement,
  revokeMessage,
  deleteMessage,
  consumeMessage,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoOperationTypeExtension on CamoOperationType {
  String get wireName {
    return switch (this) {
      CamoOperationType.encode => 'encode',
      CamoOperationType.decode => 'decode',
      CamoOperationType.pair => 'pair',
      CamoOperationType.unpair => 'unpair',
      CamoOperationType.registerDevice => 'register_device',
      CamoOperationType.approveDevice => 'approve_device',
      CamoOperationType.revokeDevice => 'revoke_device',
      CamoOperationType.validateSession => 'validate_session',
      CamoOperationType.validateLicense => 'validate_license',
      CamoOperationType.validateEntitlement => 'validate_entitlement',
      CamoOperationType.revokeMessage => 'revoke_message',
      CamoOperationType.deleteMessage => 'delete_message',
      CamoOperationType.consumeMessage => 'consume_message',
    };
  }
}
