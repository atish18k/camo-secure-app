// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum WorkspacePresenceStatus {
  online,
  activeToday,
  offline,
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class WorkspacePresenceBadge extends StatelessWidget {
  const WorkspacePresenceBadge({
    super.key,
    required this.status,
    this.timeText,
  });

  final WorkspacePresenceStatus status;
  final String? timeText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 8,
          color: _color,
        ),
        const SizedBox(width: 6),
        Text(
          _text,
          style: CamoTypography.label.copyWith(
            color: _color,
          ),
        ),
      ],
    );
  }

  Color get _color {
    switch (status) {
      case WorkspacePresenceStatus.online:
        return CamoColors.success;

      case WorkspacePresenceStatus.activeToday:
      case WorkspacePresenceStatus.offline:
        return CamoColors.textSecondary;
    }
  }

  String get _text {
    switch (status) {
      case WorkspacePresenceStatus.online:
        return 'Active Now';

      case WorkspacePresenceStatus.activeToday:
        return timeText == null
            ? 'Active Today'
            : 'Active Today • $timeText';

      case WorkspacePresenceStatus.offline:
        return 'Offline';
    }
  }
}