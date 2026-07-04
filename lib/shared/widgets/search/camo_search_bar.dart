import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_radius.dart';
import '../../../core/theme/camo_spacing.dart';

class CamoSearchBar extends StatelessWidget {
  const CamoSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller != null &&
                controller!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller!.clear();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: CamoColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CamoSpacing.md,
          vertical: CamoSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            CamoRadius.lg,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            CamoRadius.lg,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            CamoRadius.lg,
          ),
          borderSide: BorderSide(
            color: CamoColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}