import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_shadows.dart';
import '../../../core/theme/camo_spacing.dart';

class CamoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const CamoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: CamoColors.card,
        borderRadius: BorderRadius.circular(
          CamoRadius.lg,
        ),
        boxShadow: CamoShadows.card,
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(
              CamoSpacing.md,
            ),
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          CamoRadius.lg,
        ),
        onTap: onTap,
        child: card,
      ),
    );
  }
}