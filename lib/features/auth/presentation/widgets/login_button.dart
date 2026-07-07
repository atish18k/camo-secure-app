// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_typography.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

class LoginButton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool isLoading;
  final VoidCallback? onPressed;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Login',
                style: CamoTypography.button,
              ),
      ),
    );
  }
}