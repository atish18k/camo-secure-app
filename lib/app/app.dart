import 'package:flutter/material.dart';

import '../features/pairing/presentation/screens/pairing_hub_screen.dart';
import '../features/profile/presentation/screens/my_identity_screen.dart';
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
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.myIdentity:
        return _camoPageRoute(
          settings: settings,
          child: AppRoutes.protect(const MyIdentityScreen()),
        );
      case AppRoutes.myPairings:
        return _camoPageRoute(
          settings: settings,
          child: AppRoutes.protect(const PairingHubScreen()),
        );
      default:
        return null;
    }
  }

  PageRouteBuilder<dynamic> _camoPageRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
