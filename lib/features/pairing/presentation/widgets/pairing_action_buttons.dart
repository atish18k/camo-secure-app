// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_spacing.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingActionButtons extends StatelessWidget {
  const PairingActionButtons.received({
    super.key,
    required this.onAcceptTap,
    required this.onRejectTap,
  })  : mode = PairingActionMode.received,
        onPrimaryTap = null,
        onSecondaryTap = null,
        label = null,
        icon = null;

  const PairingActionButtons.single({
    super.key,
    required this.label,
    required this.icon,
    required this.onPrimaryTap,
  })  : mode = PairingActionMode.single,
        onAcceptTap = null,
        onRejectTap = null,
        onSecondaryTap = null;

  const PairingActionButtons.workspace({
    super.key,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  })  : mode = PairingActionMode.workspace,
        onAcceptTap = null,
        onRejectTap = null,
        label = null,
        icon = null;

  final PairingActionMode mode;

  final VoidCallback? onAcceptTap;
  final VoidCallback? onRejectTap;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PairingActionMode.received:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onAcceptTap,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Accept'),
              ),
            ),
            CamoSpacing.gapHorizontalSm,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRejectTap,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject'),
              ),
            ),
          ],
        );

      case PairingActionMode.single:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPrimaryTap,
            icon: Icon(icon),
            label: Text(label ?? ''),
          ),
        );

      case PairingActionMode.workspace:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onPrimaryTap,
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Encode / Decode'),
              ),
            ),
            CamoSpacing.gapHorizontalSm,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSecondaryTap,
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('Disconnect'),
              ),
            ),
          ],
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum PairingActionMode {
  received,
  single,
  workspace,
}