// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_radius.dart';
import '../../../../core/theme/camo_spacing.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingSearchBar extends StatelessWidget {
  const PairingSearchBar({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search name or CAMO ID',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        filled: true,
        fillColor: CamoColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CamoSpacing.md,
          vertical: CamoSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            CamoRadius.pill,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            CamoRadius.pill,
          ),
          borderSide: const BorderSide(
            color: CamoColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            CamoRadius.pill,
          ),
          borderSide: const BorderSide(
            color: CamoColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}