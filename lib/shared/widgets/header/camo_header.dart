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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? CamoSpacing.xs : CamoSpacing.lg,
                vertical: CamoSpacing.xs,
              ),
              child: Row(
                children: [
                  _HeaderIconButton(
                    tooltip: 'Menu',
                    icon: CamoIcons.menu,
                    onTap: onMenuTap,
                    compact: compact,
                  ),
                  Expanded(
                    child: Text(
                      'CAMO',
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: CamoTypography.appTitle.copyWith(
                        color: CamoColors.primary,
                        letterSpacing: compact ? 0.6 : 1.2,
                        fontSize: compact ? 17 : null,
                      ),
                    ),
                  ),
                  _HeaderIconButton(
                    tooltip: 'Pair Requests',
                    icon: Icons.person_add_alt_1_rounded,
                    badgeCount: pairRequestsCount,
                    onTap: onPairRequestsTap,
                    compact: compact,
                  ),
                  _HeaderIconButton(
                    tooltip: 'Notifications',
                    icon: Icons.notifications_none_rounded,
                    badgeCount: notificationCount,
                    onTap: onNotificationsTap,
                    compact: compact,
                  ),
                  _HeaderIconButton(
                    tooltip: 'Scan QR',
                    icon: CamoIcons.scanQr,
                    onTap: onScanQrTap,
                    compact: compact,
                  ),
                  _HeaderIconButton(
                    tooltip: 'Identity',
                    icon: CamoIcons.identity,
                    onTap: onIdentityTap,
                    compact: compact,
                  ),
                ],
              ),
            );
          },
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
    required this.compact,
    this.badgeCount = 0,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          constraints: BoxConstraints.tightFor(
            width: compact ? 38 : 44,
            height: compact ? 40 : 44,
          ),
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: Icon(
            icon,
            color: CamoColors.primary,
            size: compact ? 21 : CamoIcons.md,
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: compact ? 1 : 3,
            top: 2,
            child: _Badge(count: badgeCount),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
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
