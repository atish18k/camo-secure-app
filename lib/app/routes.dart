// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/pairing/presentation/screens/pair_request_screen.dart';
import '../features/pairing/presentation/screens/pending_pair_requests_screen.dart';
import '../features/pairing/presentation/screens/qr_scanner_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

// ---------------------------------------------------------------------------
// App Routes
// ---------------------------------------------------------------------------

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  static const String myIdentity = '/my-identity';

  static const String pairRequest = '/pair-request';
  static const String pendingPairRequests = '/pending-pair-requests';
  static const String myPairings = '/my-pairings';
  static const String qrScanner = '/qr-scanner';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      dashboard: (context) => const HomeScreen(),
      pairRequest: (context) => const PairRequestScreen(),
      pendingPairRequests: (context) =>
          const PendingPairRequestsScreen(),
      qrScanner: (context) => const QrScannerScreen(),
    };
  }
}