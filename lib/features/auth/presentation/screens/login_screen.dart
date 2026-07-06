import 'package:flutter/material.dart';

import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildSubtitle(context),
                  const SizedBox(height: 40),
                  const LoginForm(),
                  const SizedBox(height: 24),
                  _buildVersion(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Logo
  // ---------------------------------------------------------------------------

  Widget _buildLogo() {
    return const Icon(
      Icons.security,
      size: 72,
    );
  }

  // ---------------------------------------------------------------------------
  // Title
  // ---------------------------------------------------------------------------

  Widget _buildTitle(BuildContext context) {
    return Text(
      'CAMO',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  // ---------------------------------------------------------------------------
  // Subtitle
  // ---------------------------------------------------------------------------

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Privacy Beyond Encryption',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  // ---------------------------------------------------------------------------
  // Version
  // ---------------------------------------------------------------------------

  Widget _buildVersion(BuildContext context) {
    return Text(
      'Version 0.4.0',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}