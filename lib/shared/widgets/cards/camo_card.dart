import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_shadows.dart';
import '../../../core/theme/camo_spacing.dart';

class CamoCard extends StatelessWidget {
  const CamoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final widget = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? CamoColors.card,
        borderRadius: BorderRadius.circular(CamoRadius.lg),
        border: border,
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
      return widget;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(CamoRadius.lg),
        onTap: onTap,
        child: widget,
      ),
    );
  }
}