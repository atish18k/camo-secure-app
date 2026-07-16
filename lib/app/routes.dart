import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/pairing/presentation/screens/pair_request_screen.dart';
import '../features/pairing/presentation/screens/pending_pair_requests_screen.dart';
import '../features/pairing/presentation/screens/qr_scanner_screen.dart';
import '../features/policy/presentation/screens/camo_device_approval_gate.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/workspace/presentation/screens/workspace_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String workspace = '/workspace';
  static const String dashboard = '/dashboard';
  static const String myIdentity = '/my-identity';
  static const String pairRequest = '/pair-request';
  static const String pendingPairRequests = '/pending-pair-requests';
  static const String myPairings = '/my-pairings';
  static const String qrScanner = '/qr-scanner';

  static Widget protect(Widget child) => CamoDeviceApprovalGate(child: child);

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => protect(const WorkspaceScreen()),
    workspace: (context) => protect(const WorkspaceScreen()),
    dashboard: (context) => protect(const WorkspaceScreen()),
    pairRequest: (context) => protect(const PairRequestScreen()),
    pendingPairRequests: (context) =>
        protect(const PendingPairRequestsScreen()),
    qrScanner: (context) => protect(const QrScannerScreen()),
  };
}
