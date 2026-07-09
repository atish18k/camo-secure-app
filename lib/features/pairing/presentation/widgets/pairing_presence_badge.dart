// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum PairPresenceStatus {
  online,
  activeToday,
  offline,
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingPresenceBadge extends StatelessWidget {
  const PairingPresenceBadge({
    super.key,
    required this.status,
    this.timeText,
  });

  final PairPresenceStatus status;
  final String? timeText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
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
      case PairPresenceStatus.online:
        return CamoColors.success;

      case PairPresenceStatus.activeToday:
        return CamoColors.warning;

      case PairPresenceStatus.offline:
        return CamoColors.textSecondary;
    }
  }

  String get _text {
    switch (status) {
      case PairPresenceStatus.online:
        return 'Online';

      case PairPresenceStatus.activeToday:
        return timeText == null
            ? 'Active Today'
            : 'Active Today • $timeText';

      case PairPresenceStatus.offline:
        return 'Offline';
    }
  }
}