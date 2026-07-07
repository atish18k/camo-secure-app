// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoActionButton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: CamoIcons.sm,
                height: CamoIcons.sm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(
                icon,
                size: CamoIcons.sm,
              ),
        label: Text(
          label,
          style: CamoTypography.button,
        ),
      ),
    );
  }
}