import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';
import '../../layouts/responsive_container.dart';

class CamoHeader extends StatelessWidget {
  const CamoHeader({
    super.key,
    required this.onMenuTap,
    required this.onPairRequestsTap,
    required this.onNotificationsTap,
    required this.onScanQrTap,
    required this.onIdentityTap,
    this.pairRequestsCount = 0,
    this.notificationCount = 0,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onPairRequestsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onScanQrTap;
  final VoidCallback onIdentityTap;
  final int pairRequestsCount;
  final int notificationCount;

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
                icon: const Icon(CamoIcons.menu, color: CamoColors.icon),
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
                tooltip: 'Pair Requests',
                icon: CamoIcons.pending,
                badgeCount: pairRequestsCount,
                onTap: onPairRequestsTap,
              ),
              _HeaderIconButton(
                tooltip: 'Notifications',
                icon: Icons.notifications_none_rounded,
                badgeCount: notificationCount,
                onTap: onNotificationsTap,
              ),
              _HeaderIconButton(
                tooltip: 'Scan QR',
                icon: CamoIcons.scanQr,
                onTap: onScanQrTap,
              ),
              _HeaderIconButton(
                tooltip: 'Identity',
                icon: CamoIcons.identity,
                onTap: onIdentityTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(icon, color: CamoColors.icon, size: CamoIcons.md),
        ),
        if (badgeCount > 0)
          Positioned(right: 6, top: 6, child: _Badge(count: badgeCount)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
