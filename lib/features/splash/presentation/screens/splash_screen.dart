import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/usecases/check_auth_status_usecase.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();

    _sessionTimer = Timer(
      const Duration(seconds: 2),
      _checkSession,
    );
  }

  void _checkSession() {
    final isSignedIn = sl<CheckAuthStatusUseCase>()();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isSignedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'CAMO',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}