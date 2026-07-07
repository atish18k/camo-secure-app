// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_shadows.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoIdentityPanel extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoIdentityPanel({
    super.key,
    required this.camoId,
    required this.isVisible,
    required this.isPaired,
    required this.onVisibilityTap,
    required this.onCopyTap,
    required this.onQrTap,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String camoId;
  final bool isVisible;
  final bool isPaired;
  final VoidCallback onVisibilityTap;
  final VoidCallback onCopyTap;
  final VoidCallback onQrTap;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final String displayId = isVisible ? camoId : 'CM-XXXX-XXXX';

    return Container(
      width: double.infinity,
      padding: CamoSpacing.card,
      decoration: BoxDecoration(
        color: CamoColors.surface,
        borderRadius: BorderRadius.circular(CamoRadius.xl),
        boxShadow: CamoShadows.card,
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(-10, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CamoIcons.identity,
                  color: CamoColors.primary,
                  size: CamoIcons.md,
                ),
                CamoSpacing.gapHorizontalSm,
                Text(
                  'CAMO Identity',
                  style: CamoTypography.cardTitle.copyWith(
                    color: CamoColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          CamoSpacing.gapXxl,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isVisible ? 'Hide CAMO ID' : 'Reveal CAMO ID',
                onPressed: onVisibilityTap,
                icon: Icon(
                  isVisible ? CamoIcons.hide : CamoIcons.reveal,
                  color: CamoColors.icon,
                ),
              ),
              Text(
                displayId,
                style: CamoTypography.bodyStrong.copyWith(
                  fontSize: 18,
                  letterSpacing: 1.1,
                  color: CamoColors.textPrimary,
                ),
              ),
              IconButton(
                tooltip: 'Copy CAMO ID',
                onPressed: onCopyTap,
                icon: const Icon(
                  CamoIcons.copy,
                  color: CamoColors.icon,
                ),
              ),
            ],
          ),
          CamoSpacing.gapXxl,
          IconButton(
            tooltip: 'Show Identity QR',
            onPressed: onQrTap,
            icon: const Icon(
              CamoIcons.qr,
              size: CamoIcons.xl,
              color: CamoColors.primary,
            ),
          ),
          CamoSpacing.gapLg,
          Text(
            isPaired ? 'Paired' : 'Not Paired',
            style: CamoTypography.label.copyWith(
              color: isPaired ? CamoColors.success : CamoColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}