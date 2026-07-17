import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../domain/entities/camo_notification.dart';
import '../../domain/entities/camo_notification_feed.dart';
import '../providers/other_notifications_provider.dart';

class OtherNotificationsPanel extends ConsumerWidget {
  const OtherNotificationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CamoNotificationFeed> feed = ref.watch(
      otherNotificationsProvider,
    );
    return SafeArea(
      child: Padding(
        padding: CamoSpacing.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            CamoSpacing.gapLg,
            Expanded(
              child: feed.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _NotificationStatus(
                  icon: Icons.error_outline_rounded,
                  title: 'Notifications unavailable',
                  message: 'The notification service could not be reached.',
                ),
                data: _buildFeed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(CamoNotificationFeed feed) {
    if (!feed.isAvailable) {
      return const _NotificationStatus(
        icon: Icons.notifications_off_outlined,
        title: 'Notifications not connected',
        message:
            'Other notifications will appear after the secure service is connected.',
      );
    }
    if (feed.notifications.isEmpty) {
      return const _NotificationStatus(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        message: 'You are all caught up.',
      );
    }
    return ListView.separated(
      itemCount: feed.notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final CamoNotification item = feed.notifications[index];
        return ListTile(
          leading: Icon(
            item.isRead ? Icons.notifications_none_rounded : Icons.circle,
            color: item.isRead ? CamoColors.icon : CamoColors.primary,
            size: item.isRead ? 24 : 12,
          ),
          title: Text(item.title),
          subtitle: Text(item.message),
        );
      },
    );
  }
}

class _NotificationStatus extends StatelessWidget {
  const _NotificationStatus({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: CamoColors.icon),
          CamoSpacing.gapMd,
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          CamoSpacing.gapSm,
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
