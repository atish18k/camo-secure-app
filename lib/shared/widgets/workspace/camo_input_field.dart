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
  const CamoInputField({
    super.key,
    required this.controller,
    required this.onPasteTap,
    required this.onClearTap,
    this.hintText = 'Input',
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onPasteTap;
  final VoidCallback onClearTap;
  final String hintText;
  final bool enabled;

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
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              TextField(
                controller: controller,
                enabled: enabled,
                minLines: null,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: const EdgeInsets.fromLTRB(
                    CamoSpacing.lg,
                    CamoSpacing.md,
                    52,
                    CamoSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(CamoRadius.lg),
                  ),
                ),
              ),
              Positioned(
                top: CamoSpacing.xs,
                right: CamoSpacing.xs,
                child: IconButton(
                  tooltip: 'Clear input',
                  onPressed: enabled ? onClearTap : null,
                  icon: const Icon(
                    CamoIcons.clear,
                    color: CamoColors.primary,
                    size: CamoIcons.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
        CamoSpacing.gapXs,
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: enabled ? onPasteTap : null,
            icon: const Icon(CamoIcons.paste, size: CamoIcons.sm),
            label: const Text('Paste'),
          ),
        ),
      ],
    );
  }
}
