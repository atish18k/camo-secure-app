enum CamoNotificationType { security, account, pairing, system }

final class CamoNotification {
  const CamoNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final CamoNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
}
