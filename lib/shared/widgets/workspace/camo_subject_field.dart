// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoSubjectField extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoSubjectField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.hintText = 'Enter camouflage subject...',
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final TextEditingController controller;
  final bool enabled;
  final String hintText;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject',
          style: CamoTypography.bodyStrong,
        ),

        CamoSpacing.gapSm,

        TextField(
          controller: controller,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CamoRadius.lg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}