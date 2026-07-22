final class CamoAdminDevice {
  const CamoAdminDevice({
    required this.userId,
    required this.deviceId,
    required this.platform,
    required this.status,
    this.approvedAt,
    this.revokedAt,
    this.lastSeenAt,
  });

  factory CamoAdminDevice.fromMap(Map<String, dynamic> map) {
    DateTime? parse(String key) =>
        DateTime.tryParse((map[key] as String? ?? '').trim());
    return CamoAdminDevice(
      userId: (map['userId'] as String? ?? '').trim(),
      deviceId: (map['deviceId'] as String? ?? '').trim(),
      platform: (map['platform'] as String? ?? '').trim(),
      status: (map['status'] as String? ?? '').trim(),
      approvedAt: parse('approvedAt'),
      revokedAt: parse('revokedAt'),
      lastSeenAt: parse('lastSeenAt'),
    );
  }

  final String userId;
  final String deviceId;
  final String platform;
  final String status;
  final DateTime? approvedAt;
  final DateTime? revokedAt;
  final DateTime? lastSeenAt;

  bool get isApproved => status == 'approved';
}
