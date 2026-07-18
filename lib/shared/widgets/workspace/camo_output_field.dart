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

class CamoOutputField extends StatelessWidget {
  const CamoOutputField({
    super.key,
    required this.controller,
    required this.onCopyTap,
    required this.onShareTap,
    required this.onClearTap,
    this.hintText = 'Output',
  });

  final TextEditingController controller;
  final VoidCallback onCopyTap;
  final VoidCallback onShareTap;
  final VoidCallback onClearTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Output',
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
                readOnly: true,
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
                  tooltip: 'Clear output',
                  onPressed: onClearTap,
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
        Row(
          children: [
            TextButton.icon(
              onPressed: onCopyTap,
              icon: const Icon(CamoIcons.copy, size: CamoIcons.sm),
              label: const Text('Copy'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onShareTap,
              icon: const Icon(CamoIcons.share, size: CamoIcons.sm),
              label: const Text('Share'),
            ),
          ],
        ),
      ],
    );
  }
}
