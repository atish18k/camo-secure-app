// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class SecurityCenterCard extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const SecurityCenterCard({
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Center',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          CamoSpacing.gapLg,

          const _SecurityStatusRow(
            label: 'Encryption',
            value: 'AES-256 Ready',
          ),

          CamoSpacing.gapMd,

          const _SecurityStatusRow(
            label: 'Device',
            value: 'Verified',
          ),

          CamoSpacing.gapMd,

          const _SecurityStatusRow(
            label: 'Session',
            value: 'Protected',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _SecurityStatusRow extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _SecurityStatusRow({
    required this.label,
    required this.value,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String label;
  final String value;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const Icon(
          CamoIcons.security,
          size: CamoIcons.sm,
          color: CamoColors.success,
        ),
        CamoSpacing.gapHorizontalSm,
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CamoColors.textSecondary,
              ),
        ),
      ],
    );
  }
}