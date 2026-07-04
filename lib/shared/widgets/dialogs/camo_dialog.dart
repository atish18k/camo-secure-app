import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';
import '../button/camo_button.dart';

enum CamoDialogType {
  info,
  success,
  warning,
  danger,
}

class CamoDialog extends StatelessWidget {
  const CamoDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = CamoDialogType.info,
    this.primaryText = 'OK',
    this.secondaryText,
    this.onPrimary,
    this.onSecondary,
  });

  final String title;
  final String message;
  final CamoDialogType type;
  final String primaryText;
  final String? secondaryText;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  Color get _accentColor {
    switch (type) {
      case CamoDialogType.info:
        return CamoColors.primary;
      case CamoDialogType.success:
        return Colors.green;
      case CamoDialogType.warning:
        return Colors.orange;
      case CamoDialogType.danger:
        return CamoColors.danger;
    }
  }

  IconData get _icon {
    switch (type) {
      case CamoDialogType.info:
        return Icons.info_outline;
      case CamoDialogType.success:
        return Icons.check_circle_outline;
      case CamoDialogType.warning:
        return Icons.warning_amber_rounded;
      case CamoDialogType.danger:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryButton = type == CamoDialogType.danger
        ? CamoButton.danger(
            text: primaryText,
            onPressed: onPrimary ?? () => Navigator.pop(context),
          )
        : CamoButton.primary(
            text: primaryText,
            onPressed: onPrimary ?? () => Navigator.pop(context),
          );

    return Dialog(
      backgroundColor: CamoColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CamoRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CamoSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              color: _accentColor,
              size: 42,
            ),
            const SizedBox(height: CamoSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: CamoSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CamoColors.textSecondary,
                  ),
            ),
            const SizedBox(height: CamoSpacing.lg),
            Row(
              children: [
                if (secondaryText != null) ...[
                  Expanded(
                    child: CamoButton.secondary(
                      text: secondaryText!,
                      onPressed: onSecondary ?? () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: CamoSpacing.sm),
                ],
                Expanded(child: primaryButton),
              ],
            ),
          ],
        ),
      ),
    );
  }
}