// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';
import '../../layouts/responsive_container.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoHeader extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoHeader({
    super.key,
    required this.onMenuTap,
    required this.onPairTap,
    required this.onPendingTap,
    required this.onScanQrTap,
    required this.onSentTap,
    this.pendingCount = 0,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final VoidCallback onMenuTap;
  final VoidCallback onPairTap;
  final VoidCallback onPendingTap;
  final VoidCallback onScanQrTap;
  final VoidCallback onSentTap;
  final int pendingCount;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CamoColors.background,
      child: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CamoSpacing.lg,
            vertical: CamoSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Menu',
                onPressed: onMenuTap,
                icon: const Icon(
                  CamoIcons.menu,
                  color: CamoColors.icon,
                ),
              ),
              Text(
                'CAMO',
                style: CamoTypography.appTitle.copyWith(
                  color: CamoColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              _HeaderIconButton(
                tooltip: 'Pair Request',
                icon: CamoIcons.pair,
                onTap: onPairTap,
              ),
              _HeaderIconButton(
                tooltip: 'Pending Requests',
                icon: CamoIcons.pending,
                badgeCount: pendingCount,
                onTap: onPendingTap,
              ),
              _HeaderIconButton(
                tooltip: 'Scan QR',
                icon: CamoIcons.scanQr,
                onTap: onScanQrTap,
              ),
              _HeaderIconButton(
                tooltip: 'Sent Requests',
                icon: CamoIcons.sent,
                onTap: onSentTap,
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

class _HeaderIconButton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(
            icon,
            color: CamoColors.icon,
            size: CamoIcons.md,
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: _Badge(
              count: badgeCount,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _Badge({
    required this.count,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final int count;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      decoration: const BoxDecoration(
        color: CamoColors.badge,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: CamoTypography.label.copyWith(
          color: CamoColors.badgeText,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}