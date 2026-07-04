import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class CamoApp extends StatelessWidget {
  const CamoApp({super.key});

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