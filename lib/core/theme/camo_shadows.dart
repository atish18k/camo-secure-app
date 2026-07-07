import 'package:flutter/material.dart';

abstract final class CamoShadows {
  const CamoShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Legacy alias
  // ---------------------------------------------------------------------------

  static const List<BoxShadow> card = md;
}