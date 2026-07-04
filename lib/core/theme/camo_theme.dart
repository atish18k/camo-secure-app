import 'package:flutter/material.dart';

import 'camo_colors.dart';
import 'camo_radius.dart';
import 'camo_typography.dart';

class CamoTheme {
  const CamoTheme._();

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: CamoColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CamoColors.background,
      fontFamily: CamoTypography.fontFamily,
      textTheme: CamoTypography.textTheme(
        CamoColors.textPrimary,
        CamoColors.textSecondary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: CamoColors.background,
        foregroundColor: CamoColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: CamoColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CamoRadius.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CamoRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CamoColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CamoRadius.md),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme;
}