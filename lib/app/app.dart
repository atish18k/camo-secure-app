// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class CamoApp extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoApp({super.key});

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAMO',
      debugShowCheckedModeBanner: false,
      theme: CamoTheme.lightTheme,
      darkTheme: CamoTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}