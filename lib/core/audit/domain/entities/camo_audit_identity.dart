// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuditIdentity {
  const CamoAuditIdentity({
    required this.userId,
    required this.deviceId,
    this.pairId,
    this.messageId,
    this.sessionId,
  });
  final String userId;
  final String deviceId;
  final String? pairId;
  final String? messageId;
  final String? sessionId;
  bool get isValid {
    return userId.isNotEmpty && deviceId.isNotEmpty;
  }
}
