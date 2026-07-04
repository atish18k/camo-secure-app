import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';

enum CamoBadgeType {
  primary,
  success,
  warning,
  danger,
  neutral,
}

class CamoBadge extends StatelessWidget {
  const CamoBadge({
    super.key,
    required this.label,
    this.type = CamoBadgeType.primary,
    this.icon,
    this.padding,
  });

  final String label;
  final CamoBadgeType type;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  Color get _backgroundColor {
    switch (type) {
      case CamoBadgeType.primary:
        return CamoColors.primary;
      case CamoBadgeType.success:
        return Colors.green;
      case CamoBadgeType.warning:
        return Colors.orange;
      case CamoBadgeType.danger:
        return Colors.red;
      case CamoBadgeType.neutral:
        return CamoColors.surface;
    }
  }

  Color get _textColor {
    switch (type) {
      case CamoBadgeType.neutral:
        return CamoColors.textPrimary;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: _textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}