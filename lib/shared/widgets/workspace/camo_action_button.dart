import 'package:flutter/material.dart';

import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_typography.dart';

class CamoActionButton extends StatelessWidget {
  const CamoActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isLoading && onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: isLoading ? '$label in progress' : label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: enabled ? onPressed : null,
            icon: isLoading
                ? const SizedBox(
                    width: CamoIcons.sm,
                    height: CamoIcons.sm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, size: CamoIcons.sm),
            label: Text(label, style: CamoTypography.button),
          ),
        ),
      ),
    );
  }
}
