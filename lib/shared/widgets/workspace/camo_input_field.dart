// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoInputField extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoInputField({
    super.key,
    required this.controller,
    required this.onPasteTap,
    required this.onClearTap,
    this.hintText = 'Input',
    this.enabled = true,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final TextEditingController controller;
  final VoidCallback onPasteTap;
  final VoidCallback onClearTap;
  final String hintText;
  final bool enabled;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input',
          style: CamoTypography.bodyStrong.copyWith(
            color: CamoColors.textPrimary,
          ),
        ),
        CamoSpacing.gapSm,
        SizedBox(
          height: 128,
          child: Stack(
            children: [
              TextField(
                controller: controller,
                enabled: enabled,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: const EdgeInsets.fromLTRB(
                    CamoSpacing.lg,
                    CamoSpacing.lg,
                    52,
                    CamoSpacing.lg,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      CamoRadius.lg,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: CamoSpacing.sm,
                right: CamoSpacing.sm,
                child: IconButton(
                  tooltip: 'Clear input',
                  onPressed: enabled ? onClearTap : null,
                  icon: const Icon(
                    CamoIcons.clear,
                    color: CamoColors.icon,
                    size: CamoIcons.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
        CamoSpacing.gapSm,
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: enabled ? onPasteTap : null,
            icon: const Icon(
              CamoIcons.paste,
              size: CamoIcons.sm,
            ),
            label: const Text('Paste'),
          ),
        ),
      ],
    );
  }
}