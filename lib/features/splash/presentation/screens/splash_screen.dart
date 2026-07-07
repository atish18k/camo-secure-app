// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/camo_typography.dart';
import '../../../auth/domain/usecases/check_auth_status_usecase.dart';

// ---------------------------------------------------------------------------
// Splash Screen
// ---------------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const SplashScreen({
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Create State
  // ---------------------------------------------------------------------------

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _SplashScreenState extends State<SplashScreen> {
  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  Timer? _sessionTimer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _sessionTimer = Timer(
      const Duration(seconds: 2),
      _checkSession,
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  void _checkSession() {
    final bool isSignedIn = sl<CheckAuthStatusUseCase>()();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      isSignedIn ? AppRoutes.dashboard : AppRoutes.login,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'CAMO',
          style: CamoTypography.appTitle.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}