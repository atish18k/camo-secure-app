import '../entities/camo_notification_feed.dart';

abstract interface class CamoNotificationRepository {
  Stream<CamoNotificationFeed> watchFeed();
}
