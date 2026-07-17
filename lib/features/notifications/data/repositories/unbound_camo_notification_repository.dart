import '../../domain/entities/camo_notification_feed.dart';
import '../../domain/repositories/camo_notification_repository.dart';

final class UnboundCamoNotificationRepository
    implements CamoNotificationRepository {
  const UnboundCamoNotificationRepository();

  @override
  Stream<CamoNotificationFeed> watchFeed() {
    return Stream<CamoNotificationFeed>.value(
      const CamoNotificationFeed.unavailable(),
    );
  }
}
