// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoAuditCategory {
  authentication,
  authorization,
  deviceTrust,
  policy,
  risk,
  commercial,
  keyManagement,
  securitySession,
  operation,
  messageLifecycle,
  runtimeIntegrity,
  recovery,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoAuditCategoryExtension on CamoAuditCategory {
  String get wireName {
    return switch (this) {
      CamoAuditCategory.authentication => 'authentication',
      CamoAuditCategory.authorization => 'authorization',
      CamoAuditCategory.deviceTrust => 'device_trust',
      CamoAuditCategory.policy => 'policy',
      CamoAuditCategory.risk => 'risk',
      CamoAuditCategory.commercial => 'commercial',
      CamoAuditCategory.keyManagement => 'key_management',
      CamoAuditCategory.securitySession => 'security_session',
      CamoAuditCategory.operation => 'operation',
      CamoAuditCategory.messageLifecycle => 'message_lifecycle',
      CamoAuditCategory.runtimeIntegrity => 'runtime_integrity',
      CamoAuditCategory.recovery => 'recovery',
    };
  }
}
