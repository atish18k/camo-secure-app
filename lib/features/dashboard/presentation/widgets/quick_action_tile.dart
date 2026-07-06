import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (iconColor ?? CamoColors.primary).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? CamoColors.primary,
              size: 26,
            ),
          ),

          const SizedBox(height: CamoSpacing.md),

          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CamoColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}