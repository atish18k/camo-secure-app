enum CamoAdminDeviceRequestStatus { pending, approved, rejected }

final class CamoAdminDeviceRequest {
  const CamoAdminDeviceRequest({
    required this.requestId,
    required this.userId,
    required this.userEmail,
    required this.deviceId,
    required this.deviceLabel,
    required this.platform,
    required this.requestedAt,
    required this.status,
  });

  final String requestId;
  final String userId;
  final String userEmail;
  final String deviceId;
  final String deviceLabel;
  final String platform;
  final DateTime requestedAt;
  final CamoAdminDeviceRequestStatus status;
}
