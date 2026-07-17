import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/unbound_camo_notification_repository.dart';
import '../../domain/entities/camo_notification_feed.dart';
import '../../domain/repositories/camo_notification_repository.dart';

final otherNotificationsRepositoryProvider =
    Provider<CamoNotificationRepository>((ref) {
      return const UnboundCamoNotificationRepository();
    });

final otherNotificationsProvider = StreamProvider<CamoNotificationFeed>((ref) {
  return ref.watch(otherNotificationsRepositoryProvider).watchFeed();
});
