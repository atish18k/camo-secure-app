import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';

class CamoBottomSheet extends StatelessWidget {
  const CamoBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.showHandle = true,
  });

  final String title;
  final Widget child;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: CamoColors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(CamoRadius.xl),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CamoSpacing.lg,
            CamoSpacing.md,
            CamoSpacing.lg,
            CamoSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHandle) ...[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CamoColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: CamoSpacing.md),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: CamoSpacing.lg),
              child,
            ],
          ),
        ),
      ),
    );
  }
}