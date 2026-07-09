// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingStatus extends StatelessWidget {
  const PairingStatus({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: CamoTypography.label.copyWith(
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Factory Constructors
  // ---------------------------------------------------------------------------

  factory PairingStatus.connected({
    String text = 'Connected',
  }) {
    return PairingStatus(
      text: text,
      color: CamoColors.success,
    );
  }

  factory PairingStatus.pending({
    String text = 'Pending',
  }) {
    return PairingStatus(
      text: text,
      color: CamoColors.warning,
    );
  }

  factory PairingStatus.rejected({
    String text = 'Rejected',
  }) {
    return PairingStatus(
      text: text,
      color: CamoColors.error,
    );
  }

  factory PairingStatus.inactive({
    String text = 'Inactive',
  }) {
    return PairingStatus(
      text: text,
      color: CamoColors.textSecondary,
    );
  }
}