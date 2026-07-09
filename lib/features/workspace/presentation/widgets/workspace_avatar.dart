// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class WorkspaceAvatar extends StatelessWidget {
  const WorkspaceAvatar({
    super.key,
    this.isOnline = true,
  });

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: CamoColors.background,
          child: Icon(
            CamoIcons.profile,
            color: CamoColors.primary,
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: isOnline
                  ? CamoColors.success
                  : CamoColors.textSecondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: CamoColors.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}