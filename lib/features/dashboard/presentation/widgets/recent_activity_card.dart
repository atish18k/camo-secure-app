import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({
    super.key,
    this.activities = const [
      RecentActivityItem(
        title: 'Identity Viewed',
        timeLabel: 'Just now',
        icon: Icons.visibility_outlined,
      ),
      RecentActivityItem(
        title: 'CAMO ID Copied',
        timeLabel: '2 min ago',
        icon: Icons.copy_outlined,
      ),
      RecentActivityItem(
        title: 'Pair Request Sent',
        timeLabel: 'Yesterday',
        icon: Icons.link,
      ),
    ],
  });

  final List<RecentActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: CamoSpacing.lg),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Recent Activity',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (activities.isEmpty) {
      return Text(
        'No recent activity yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CamoColors.textSecondary,
            ),
      );
    }

    return Column(
      children: activities
          .map(
            (RecentActivityItem item) => Padding(
              padding: const EdgeInsets.only(bottom: CamoSpacing.md),
              child: _RecentActivityRow(item: item),
            ),
          )
          .toList(),
    );
  }
}

class RecentActivityItem {
  const RecentActivityItem({
    required this.title,
    required this.timeLabel,
    required this.icon,
  });

  final String title;
  final String timeLabel;
  final IconData icon;
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({
    required this.item,
  });

  final RecentActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          item.icon,
          size: 18,
          color: CamoColors.textSecondary,
        ),
        const SizedBox(width: CamoSpacing.sm),
        Expanded(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: CamoSpacing.sm),
        Text(
          item.timeLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CamoColors.textSecondary,
              ),
        ),
      ],
    );
  }
}