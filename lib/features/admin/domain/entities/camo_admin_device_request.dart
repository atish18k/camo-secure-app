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

  factory CamoAdminDeviceRequest.fromMap(Map<String, dynamic> map) {
    final String statusValue = (map['status'] as String? ?? '').trim();
    final CamoAdminDeviceRequestStatus status = switch (statusValue) {
      'approved' => CamoAdminDeviceRequestStatus.approved,
      'rejected' => CamoAdminDeviceRequestStatus.rejected,
      _ => CamoAdminDeviceRequestStatus.pending,
    };
    return CamoAdminDeviceRequest(
      requestId: (map['requestId'] as String? ?? '').trim(),
      userId: (map['userId'] as String? ?? '').trim(),
      userEmail: (map['userEmail'] as String? ?? '').trim(),
      deviceId: (map['deviceId'] as String? ?? '').trim(),
      deviceLabel: (map['deviceLabel'] as String? ?? 'Device').trim(),
      platform: (map['platform'] as String? ?? '').trim(),
      requestedAt:
          DateTime.tryParse((map['requestedAt'] as String? ?? '').trim()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      status: status,
    );
  }

  final String requestId;
  final String userId;
  final String userEmail;
  final String deviceId;
  final String deviceLabel;
  final String platform;
  final DateTime requestedAt;
  final CamoAdminDeviceRequestStatus status;
}
