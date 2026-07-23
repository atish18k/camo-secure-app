import 'package:flutter/material.dart';

import 'camo_colors.dart';
import 'camo_radius.dart';
import 'camo_typography.dart';

abstract final class CamoTheme {
  const CamoTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: CamoColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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
        color: CamoColors.surface,
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
        fillColor: CamoColors.inputBackground,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CamoRadius.md),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CamoRadius.md),
          borderSide: const BorderSide(color: CamoColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CamoRadius.md),
          borderSide: const BorderSide(color: CamoColors.primary),
        ),
      ),
    );
  }

  // Dark mode uses the locked light theme until its dedicated palette is implemented.
  static ThemeData get darkTheme => lightTheme;
}
