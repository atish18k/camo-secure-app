import 'package:flutter/material.dart';

abstract final class CamoTypography {
  const CamoTypography._();

  static const String fontFamily = 'Roboto';

  static const TextStyle appTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static TextTheme textTheme(
    Color primary,
    Color secondary,
  ) {
    return TextTheme(
      titleLarge: appTitle.copyWith(color: primary),
      titleMedium: cardTitle.copyWith(color: primary),
      bodyMedium: body.copyWith(color: primary),
      bodySmall: label.copyWith(color: secondary),
      labelLarge: button.copyWith(color: primary),
    );
  }
}