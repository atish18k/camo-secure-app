import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../providers/workspace_state.dart';

class CamoWorkspaceOperationBanner extends StatelessWidget {
  const CamoWorkspaceOperationBanner({super.key, required this.status});
  final CamoWorkspaceOperationStatus status;

  @override
  Widget build(BuildContext context) {
    final _OperationPresentation presentation = _presentation(status);
    return Semantics(
      container: true,
      excludeSemantics: true,
      liveRegion: true,
      label: 'Workspace operation status: ${presentation.label}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: CamoSpacing.md,
          vertical: CamoSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: presentation.color.withValues(alpha: 0.12),
          border: Border.all(color: presentation.color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(presentation.icon, color: presentation.color, size: 18),
            CamoSpacing.gapHorizontalSm,
            Expanded(child: Text(presentation.label)),
          ],
        ),
      ),
    );
  }

  _OperationPresentation _presentation(CamoWorkspaceOperationStatus status) {
    return switch (status) {
      CamoWorkspaceOperationStatus.ready => const _OperationPresentation(
        'Ready',
        Icons.check_circle_outline,
        CamoColors.primary,
      ),
      CamoWorkspaceOperationStatus.authorizing => const _OperationPresentation(
        'Authorizing with server',
        Icons.verified_user_outlined,
        CamoColors.warning,
      ),
      CamoWorkspaceOperationStatus.processing => const _OperationPresentation(
        'Processing authorized operation',
        Icons.sync,
        CamoColors.info,
      ),
      CamoWorkspaceOperationStatus.success => const _OperationPresentation(
        'Operation completed',
        Icons.task_alt,
        CamoColors.success,
      ),
      CamoWorkspaceOperationStatus.failure => const _OperationPresentation(
        'Operation failed',
        Icons.error_outline,
        CamoColors.error,
      ),
      CamoWorkspaceOperationStatus.expired => const _OperationPresentation(
        'Authorization expired',
        Icons.timer_off_outlined,
        CamoColors.warning,
      ),
      CamoWorkspaceOperationStatus.blocked => const _OperationPresentation(
        'Operation blocked',
        Icons.block,
        CamoColors.error,
      ),
    };
  }
}

class _OperationPresentation {
  const _OperationPresentation(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
