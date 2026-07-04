import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';

enum CamoButtonVariant {
  primary,
  secondary,
  outlined,
  danger,
}

class CamoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final CamoButtonVariant variant;

  const CamoButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = CamoButtonVariant.primary;

  const CamoButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = CamoButtonVariant.secondary;

  const CamoButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = CamoButtonVariant.outlined;

  const CamoButton.danger({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = CamoButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final enabled = !isLoading && onPressed != null;

    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CamoRadius.md),
    );

    switch (variant) {
      case CamoButtonVariant.primary:
        return SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: CamoColors.primary,
              foregroundColor: CamoColors.white,
              shape: shape,
            ),
            child: child,
          ),
        );

      case CamoButtonVariant.secondary:
        return SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: CamoColors.surface,
              foregroundColor: CamoColors.textPrimary,
              shape: shape,
            ),
            child: child,
          ),
        );

      case CamoButtonVariant.outlined:
        return SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: CamoColors.textPrimary,
              side: const BorderSide(color: CamoColors.border),
              shape: shape,
            ),
            child: child,
          ),
        );

      case CamoButtonVariant.danger:
        return SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: CamoColors.danger,
              foregroundColor: CamoColors.white,
              shape: shape,
            ),
            child: child,
          ),
        );
    }
  }
}