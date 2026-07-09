// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class WorkspaceCopyButton extends StatelessWidget {
  const WorkspaceCopyButton({
    super.key,
    required this.onTap,
    this.tooltip = 'Copy CAMO ID',
  });

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: onTap,
      icon: const Icon(
        Icons.copy_rounded,
        size: 18,
        color: CamoColors.icon,
      ),
    );
  }
}