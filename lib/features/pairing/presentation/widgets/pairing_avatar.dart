// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingAvatar extends StatelessWidget {
  const PairingAvatar({
    super.key,
    this.radius = 24,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: CamoColors.background,
      child: Icon(
        CamoIcons.profile,
        color: CamoColors.primary,
        size: radius,
      ),
    );
  }
}