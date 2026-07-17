import 'package:camo/features/notifications/domain/entities/camo_notification.dart';
import 'package:camo/features/notifications/domain/entities/camo_notification_feed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unavailable feed is fail-closed with zero unread count', () {
    const CamoNotificationFeed feed = CamoNotificationFeed.unavailable();
    expect(feed.isAvailable, isFalse);
    expect(feed.notifications, isEmpty);
    expect(feed.unreadCount, 0);
  });

  test('available feed derives unread count from immutable items', () {
    final CamoNotificationFeed feed = CamoNotificationFeed.available([
      CamoNotification(
        id: 'n1',
        type: CamoNotificationType.security,
        title: 'Security',
        message: 'Review activity.',
        createdAt: DateTime.utc(2026),
        isRead: false,
      ),
      CamoNotification(
        id: 'n2',
        type: CamoNotificationType.system,
        title: 'System',
        message: 'Completed.',
        createdAt: DateTime.utc(2026),
        isRead: true,
      ),
    ]);
    expect(feed.isAvailable, isTrue);
    expect(feed.unreadCount, 1);
    expect(() => feed.notifications.clear(), throwsUnsupportedError);
  });
}
