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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
