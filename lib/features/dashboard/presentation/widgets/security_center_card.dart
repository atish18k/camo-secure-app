// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class SecurityCenterCard extends StatelessWidget {
  const SecurityCenterCard({super.key});

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
          const SizedBox(height: CamoSpacing.lg),

          _SecurityStatusRow(
            label: 'Encryption',
            value: 'AES-256 Ready',
          ),

          const SizedBox(height: CamoSpacing.md),

          _SecurityStatusRow(
            label: 'Device',
            value: 'Verified',
          ),

          const SizedBox(height: CamoSpacing.md),

          _SecurityStatusRow(
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
  const _SecurityStatusRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
          Icons.verified_outlined,
          size: 18,
          color: CamoColors.success,
        ),
        const SizedBox(width: CamoSpacing.xs),
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