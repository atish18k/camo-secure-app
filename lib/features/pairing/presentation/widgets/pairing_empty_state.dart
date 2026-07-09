// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingEmptyState extends StatelessWidget {
  const PairingEmptyState({
    super.key,
    required this.message,
    this.icon = CamoIcons.pair,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: CamoSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: CamoColors.textSecondary,
            ),
            CamoSpacing.gapMd,
            Text(
              message,
              textAlign: TextAlign.center,
              style: CamoTypography.body.copyWith(
                color: CamoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}