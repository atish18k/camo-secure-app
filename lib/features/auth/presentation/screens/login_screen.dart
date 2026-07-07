import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: CamoSpacing.screen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
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
      ),
    );
  }

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