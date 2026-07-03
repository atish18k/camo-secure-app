import 'package:flutter/material.dart';

import '../features/splash/presentation/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
    };
  }
}