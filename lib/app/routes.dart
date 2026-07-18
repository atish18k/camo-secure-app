import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/create_account_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/passkey_setup_screen.dart';
import '../features/dashboard/presentation/screens/security_center_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/pairing/presentation/screens/pair_request_screen.dart';
import '../features/pairing/presentation/screens/pending_pair_requests_screen.dart';
import '../features/pairing/presentation/screens/qr_scanner_screen.dart';
import '../features/policy/presentation/screens/camo_device_approval_gate.dart';
import '../features/policy/presentation/screens/camo_device_eligibility_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/subscription/presentation/screens/activate_plan_screen.dart';
import '../features/subscription/presentation/screens/choose_plan_screen.dart';
import '../features/subscription/presentation/screens/subscription_screen.dart';
import '../features/workspace/presentation/screens/workspace_screen.dart';

class AppRoutes {
  const AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String verifyEmail = '/verify-email';
  static const String passkeySetup = '/passkey-setup';
  static const String deviceEligibility = '/device-eligibility';
  static const String home = '/home';
  static const String workspace = '/workspace';
  static const String history = '/history';
  static const String securityCenter = '/security-center';
  static const String choosePlan = '/choose-plan';
  static const String planActivation = '/activate-plan';
  static const String subscription = '/subscription';
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
    createAccount: (context) => const CreateAccountScreen(),
    verifyEmail: (context) => const EmailVerificationScreen(),
    passkeySetup: (context) => const PasskeySetupScreen(),
    deviceEligibility: (context) => const CamoDeviceEligibilityScreen(),
    home: (context) => protect(const WorkspaceScreen()),
    workspace: (context) => protect(const WorkspaceScreen()),
    history: (context) => protect(const HistoryScreen()),
    securityCenter: (context) => protect(const SecurityCenterScreen()),
    choosePlan: (context) => protect(const ChoosePlanScreen()),
    planActivation: (context) => protect(const ActivatePlanScreen()),
    subscription: (context) => protect(const SubscriptionScreen()),
    dashboard: (context) => protect(const WorkspaceScreen()),
    pairRequest: (context) => protect(const PairRequestScreen()),
    pendingPairRequests: (context) =>
        protect(const PendingPairRequestsScreen()),
    qrScanner: (context) => protect(const QrScannerScreen()),
  };
}
