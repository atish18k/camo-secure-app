import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
    };
  }
}
