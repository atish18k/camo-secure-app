// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_radius.dart';
import '../../../../core/theme/camo_typography.dart';
import '../providers/pairing_hub_state.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingTabs extends StatelessWidget {
  const PairingTabs({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final PairingHubState state;
  final ValueChanged<PairingHubTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: 'Received',
          count: state.receivedCount,
          icon: Icons.inbox_outlined,
          selected: state.selectedTab == PairingHubTab.received,
          onTap: () => onChanged(PairingHubTab.received),
        ),
        _TabItem(
          label: 'Sent',
          count: state.sentCount,
          icon: Icons.outbox_outlined,
          selected: state.selectedTab == PairingHubTab.sent,
          onTap: () => onChanged(PairingHubTab.sent),
        ),
        _TabItem(
          label: 'Paired',
          count: state.pairedCount,
          icon: Icons.people_outline_rounded,
          selected: state.selectedTab == PairingHubTab.paired,
          onTap: () => onChanged(PairingHubTab.paired),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? CamoColors.primary : CamoColors.textSecondary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(CamoRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                '$label ($count)',
                style: CamoTypography.label.copyWith(
                  color: color,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: selected ? 56 : 0,
                decoration: BoxDecoration(
                  color: CamoColors.primary,
                  borderRadius:
                      BorderRadius.circular(CamoRadius.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}