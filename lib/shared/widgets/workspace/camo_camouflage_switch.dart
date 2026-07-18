// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoCamouflageSwitch extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoCamouflageSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool value;
  final ValueChanged<bool>? onChanged;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Camouflage (Coming later)',
          style: CamoTypography.bodyStrong.copyWith(
            color: CamoColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value ? 'ON' : 'OFF',
          style: CamoTypography.label.copyWith(
            color: value ? CamoColors.primary : CamoColors.textSecondary,
          ),
        ),
        const SizedBox(width: CamoSpacing.sm),
        Switch(
          value: value,
          activeThumbColor: CamoColors.primary,
          activeTrackColor: CamoColors.primaryLight,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
