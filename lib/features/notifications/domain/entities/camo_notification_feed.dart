import 'camo_notification.dart';

final class CamoNotificationFeed {
  CamoNotificationFeed.available(List<CamoNotification> notifications)
    : isAvailable = true,
      notifications = List<CamoNotification>.unmodifiable(notifications);

  const CamoNotificationFeed.unavailable()
    : isAvailable = false,
      notifications = const <CamoNotification>[];

  final bool isAvailable;
  final List<CamoNotification> notifications;

  int get unreadCount => isAvailable
      ? notifications.where((CamoNotification item) => !item.isRead).length
      : 0;
}
