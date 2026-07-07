// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../widgets/login_form.dart';

// ---------------------------------------------------------------------------
// Login Screen
// ---------------------------------------------------------------------------

class LoginScreen extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const LoginScreen({
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: CamoSpacing.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(),
                CamoSpacing.gapXxl,
                _buildTitle(context),
                CamoSpacing.gapSm,
                _buildSubtitle(context),
                CamoSpacing.gapXxl,
                const LoginForm(),
                CamoSpacing.gapXxl,
                _buildVersion(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private Widgets
  // ---------------------------------------------------------------------------

  Widget _buildLogo() {
    return const Icon(
      CamoIcons.security,
      size: 72,
      color: CamoColors.primary,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'CAMO',
      textAlign: TextAlign.center,
      style: CamoTypography.appTitle.copyWith(
        fontSize: 32,
        letterSpacing: 4,
        color: CamoColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Privacy Beyond Encryption',
      textAlign: TextAlign.center,
      style: CamoTypography.body.copyWith(
        color: CamoColors.textSecondary,
      ),
    );
  }

  Widget _buildVersion(BuildContext context) {
    return Text(
      'Version 0.15.1',
      textAlign: TextAlign.center,
      style: CamoTypography.label.copyWith(
        color: CamoColors.textHint,
      ),
    );
  }
}