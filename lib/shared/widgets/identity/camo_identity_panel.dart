import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_shadows.dart';
import '../../../core/theme/camo_typography.dart';

class CamoIdentityPanel extends StatelessWidget {
  const CamoIdentityPanel({
    super.key,
    required this.camoId,
    required this.isVisible,
    required this.isPaired,
    required this.onVisibilityTap,
    required this.onCopyTap,
    required this.onQrTap,
  });
  final String camoId;
  final bool isVisible;
  final bool isPaired;
  final VoidCallback onVisibilityTap;
  final VoidCallback onCopyTap;
  final VoidCallback onQrTap;

  @override
  Widget build(BuildContext context) {
    final displayId = isVisible ? camoId : 'CM-XXXX-XXXX';
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CamoColors.surface,
        borderRadius: BorderRadius.circular(CamoRadius.lg),
        boxShadow: CamoShadows.md,
        border: Border.all(color: CamoColors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(CamoIcons.identity, color: CamoColors.primary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAMO Identity', style: CamoTypography.bodyStrong),
                const SizedBox(height: 2),
                Text(
                  displayId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CamoTypography.label.copyWith(
                    color: CamoColors.textPrimary,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaired ? 'Paired' : 'Not Paired',
                  style: CamoTypography.label.copyWith(
                    color: isPaired ? CamoColors.success : CamoColors.warning,
                  ),
                ),
              ],
            ),
          ),
          _CompactAction(
            tooltip: isVisible ? 'Hide CAMO ID' : 'Reveal CAMO ID',
            icon: isVisible ? CamoIcons.hide : CamoIcons.reveal,
            onTap: onVisibilityTap,
          ),
          _CompactAction(
            tooltip: 'Copy CAMO ID',
            icon: CamoIcons.copy,
            onTap: onCopyTap,
          ),
          _CompactAction(
            tooltip: 'Show Identity QR',
            icon: CamoIcons.qr,
            onTap: onQrTap,
            primary: true,
          ),
        ],
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints.tightFor(width: 36, height: 40),
    padding: EdgeInsets.zero,
    onPressed: onTap,
    icon: Icon(
      icon,
      size: 20,
      color: primary ? CamoColors.primary : CamoColors.icon,
    ),
  );
}
