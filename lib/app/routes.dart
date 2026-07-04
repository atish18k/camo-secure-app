import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/pairing/presentation/screens/incoming_pair_requests_screen.dart';
import '../features/pairing/presentation/screens/pair_request_screen.dart';
import '../features/pairing/presentation/screens/pairing_hub_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  // Pairing
  static const String pairingHub = '/pairing';
  static const String pairRequest = '/pair-request';
  static const String incomingPairRequests =
      '/incoming-pair-requests';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),

      // Pairing
      pairingHub: (context) => const PairingHubScreen(),
      pairRequest: (context) => const PairRequestScreen(),
      incomingPairRequests: (context) =>
          const IncomingPairRequestsScreen(),
    };
  }
}