import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';

enum CamoAvatarSize {
  small,
  medium,
  large,
}

class CamoAvatar extends StatelessWidget {
  const CamoAvatar({
    super.key,
    this.imageProvider,
    this.initials,
    this.icon,
    this.size = CamoAvatarSize.medium,
    this.backgroundColor,
  });

  final ImageProvider? imageProvider;
  final String? initials;
  final IconData? icon;
  final CamoAvatarSize size;
  final Color? backgroundColor;

  double get _dimension {
    switch (size) {
      case CamoAvatarSize.small:
        return 36;
      case CamoAvatarSize.medium:
        return 52;
      case CamoAvatarSize.large:
        return 72;
    }
  }

  double get _iconSize {
    switch (size) {
      case CamoAvatarSize.small:
        return 18;
      case CamoAvatarSize.medium:
        return 24;
      case CamoAvatarSize.large:
        return 32;
    }
  }

  double get _fontSize {
    switch (size) {
      case CamoAvatarSize.small:
        return 14;
      case CamoAvatarSize.medium:
        return 18;
      case CamoAvatarSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: _dimension / 2,
      backgroundColor: backgroundColor ?? CamoColors.primary,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? initials != null
              ? Text(
                  initials!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize,
                  ),
                )
              : Icon(
                  icon ?? Icons.person,
                  color: Colors.white,
                  size: _iconSize,
                )
          : null,
    );
  }
}