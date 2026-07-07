// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum CamoPairStatus {
  online,
  away,
  offline,
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoPairSelector extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoPairSelector({
    super.key,
    required this.onTap,
    this.selectedPairLabel,
    this.status = CamoPairStatus.offline,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String? selectedPairLabel;
  final CamoPairStatus status;
  final VoidCallback onTap;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        selectedPairLabel != null && selectedPairLabel!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CamoRadius.pill),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: CamoSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: CamoColors.surface,
            borderRadius: BorderRadius.circular(CamoRadius.pill),
            border: Border.all(
              color: CamoColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CamoIcons.profile,
                size: CamoIcons.sm,
                color: CamoColors.primary,
              ),
              CamoSpacing.gapHorizontalSm,
              Flexible(
                child: Text(
                  hasSelection ? selectedPairLabel! : 'Select Pair',
                  overflow: TextOverflow.ellipsis,
                  style: CamoTypography.bodyStrong.copyWith(
                    color: hasSelection
                        ? CamoColors.textPrimary
                        : CamoColors.textSecondary,
                  ),
                ),
              ),
              if (hasSelection) ...[
                CamoSpacing.gapHorizontalSm,
                _StatusDot(
                  status: status,
                ),
              ],
              CamoSpacing.gapHorizontalSm,
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: CamoIcons.sm,
                color: CamoColors.icon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _StatusDot extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _StatusDot({
    required this.status,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final CamoPairStatus status;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: _statusColor,
        shape: BoxShape.circle,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color get _statusColor {
    switch (status) {
      case CamoPairStatus.online:
        return CamoColors.success;

      case CamoPairStatus.away:
        return CamoColors.warning;

      case CamoPairStatus.offline:
        return CamoColors.error;
    }
  }
}