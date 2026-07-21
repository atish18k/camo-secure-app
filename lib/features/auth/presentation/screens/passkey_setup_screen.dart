import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_spacing.dart';

class PasskeySetupScreen extends StatelessWidget {
  const PasskeySetupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passkey setup')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: CamoSpacing.screen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.key_outlined, size: 64),
                  CamoSpacing.gapLg,
                  const Text(
                    'Passkey enrollment is not enabled in this build.',
                    textAlign: TextAlign.center,
                  ),
                  CamoSpacing.gapSm,
                  const Text(
                    'Verified email remains the active sign-in method. CAMO will not display a fake passkey success state.',
                    textAlign: TextAlign.center,
                  ),
                  CamoSpacing.gapLg,
                  FilledButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.postLogin,
                    ),
                    child: const Text('Continue with verified email'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
