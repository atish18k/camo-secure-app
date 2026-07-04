import 'package:flutter/material.dart';

import '../core/theme/camo_theme.dart' as core_theme;

class CamoTheme {
  const CamoTheme._();

  static ThemeData get darkTheme =>
      core_theme.CamoTheme.darkTheme;

  static ThemeData get lightTheme =>
      core_theme.CamoTheme.lightTheme;
}