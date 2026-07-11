// -----------------------------------------------------------------------------
// Enum
// -----------------------------------------------------------------------------
enum CamoSecuritySessionTerminationReason {
  completed,
  userLogout,
  remoteLogout,
  deviceRevoked,
  authorizationConsumed,
  riskEscalated,
  policyDenied,
  expired,
  securityIncident,
}

// -----------------------------------------------------------------------------
// Extension
// -----------------------------------------------------------------------------
extension CamoSecuritySessionTerminationReasonExtension
    on CamoSecuritySessionTerminationReason {
  String get wireName {
    return switch (this) {
      CamoSecuritySessionTerminationReason.completed => 'completed',
      CamoSecuritySessionTerminationReason.userLogout => 'user_logout',
      CamoSecuritySessionTerminationReason.remoteLogout => 'remote_logout',
      CamoSecuritySessionTerminationReason.deviceRevoked => 'device_revoked',
      CamoSecuritySessionTerminationReason.authorizationConsumed =>
        'authorization_consumed',
      CamoSecuritySessionTerminationReason.riskEscalated => 'risk_escalated',
      CamoSecuritySessionTerminationReason.policyDenied => 'policy_denied',
      CamoSecuritySessionTerminationReason.expired => 'expired',
      CamoSecuritySessionTerminationReason.securityIncident =>
        'security_incident',
    };
  }
}
