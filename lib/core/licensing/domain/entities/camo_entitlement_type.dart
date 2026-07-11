// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoEntitlementType {
  baseEncoding,
  baseDecoding,
  camouflage,
  oneTimeView,
  burnAfterRead,
  messageExpiry,
  deviceManagement,
  enterpriseAudit,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoEntitlementTypeExtension on CamoEntitlementType {
  String get wireName {
    return switch (this) {
      CamoEntitlementType.baseEncoding => 'base_encoding',
      CamoEntitlementType.baseDecoding => 'base_decoding',
      CamoEntitlementType.camouflage => 'camouflage',
      CamoEntitlementType.oneTimeView => 'one_time_view',
      CamoEntitlementType.burnAfterRead => 'burn_after_read',
      CamoEntitlementType.messageExpiry => 'message_expiry',
      CamoEntitlementType.deviceManagement => 'device_management',
      CamoEntitlementType.enterpriseAudit => 'enterprise_audit',
    };
  }
}
