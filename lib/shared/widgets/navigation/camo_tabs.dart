// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum CamoWorkspaceTab { encoder, decoder }

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoTabs extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoTabs({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final CamoWorkspaceTab selectedTab;
  final ValueChanged<CamoWorkspaceTab> onChanged;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CamoRadius.lg),
        border: Border.all(color: CamoColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'CAMO Mode',
              selected: selectedTab == CamoWorkspaceTab.encoder,
              onTap: () => onChanged(CamoWorkspaceTab.encoder),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: 'UNCAMO Mode',
              selected: selectedTab == CamoWorkspaceTab.decoder,
              onTap: () => onChanged(CamoWorkspaceTab.decoder),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _TabButton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _TabButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String title;
  final bool selected;
  final VoidCallback onTap;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(CamoRadius.lg),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? CamoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(CamoRadius.lg),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: selected ? Colors.white : CamoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
