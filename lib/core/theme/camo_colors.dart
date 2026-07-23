import 'package:flutter/material.dart';

abstract final class CamoColors {
  const CamoColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF00897B);
  static const Color primaryDark = Color(0xFF004D40);

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Color(0xFF9E9E9E);

  // ---------------------------------------------------------------------------
  // Border
  // ---------------------------------------------------------------------------

  static const Color border = Color(0xFFE0E0E0);

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  // ---------------------------------------------------------------------------
  // Badge
  // ---------------------------------------------------------------------------

  static const Color badge = Color(0xFFD32F2F);
  static const Color badgeText = Colors.white;

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

  static const Color icon = Color(0xFF424242);
  static const Color iconDisabled = Color(0xFFBDBDBD);

  // ---------------------------------------------------------------------------
  // Inputs
  // ---------------------------------------------------------------------------

  static const Color inputBackground = Colors.white;
}
