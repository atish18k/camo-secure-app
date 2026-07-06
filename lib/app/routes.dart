// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/pairing/presentation/screens/my_pairings_screen.dart';
import '../features/pairing/presentation/screens/pair_request_screen.dart';
import '../features/pairing/presentation/screens/pending_pair_requests_screen.dart';
import '../features/pairing/presentation/screens/qr_scanner_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

// ---------------------------------------------------------------------------
// App Routes
// ---------------------------------------------------------------------------

class AppRoutes {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const AppRoutes._();

  // ---------------------------------------------------------------------------
  // Core Routes
  // ---------------------------------------------------------------------------

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // ---------------------------------------------------------------------------
  // Pairing Routes
  // ---------------------------------------------------------------------------

  static const String pairRequest = '/pair-request';
  static const String pendingPairRequests = '/pending-pair-requests';
  static const String myPairings = '/my-pairings';
  static const String qrScanner = '/qr-scanner';

  // ---------------------------------------------------------------------------
  // Route Map
  // ---------------------------------------------------------------------------

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      dashboard: (context) => const DashboardScreen(),
      pairRequest: (context) => const PairRequestScreen(),
      pendingPairRequests: (context) => const PendingPairRequestsScreen(),
      myPairings: (context) => const MyPairingsScreen(),
      qrScanner: (context) => const QrScannerScreen(),
    };
  }
}