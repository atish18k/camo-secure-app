// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import 'workspace_avatar.dart';
import 'workspace_copy_button.dart';
import 'workspace_presence_badge.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class WorkspacePairHeader extends StatelessWidget {
  const WorkspacePairHeader({
    super.key,
    required this.displayName,
    required this.camoId,
    required this.onTap,
    this.onCopyTap,
    this.presenceStatus = WorkspacePresenceStatus.online,
    this.lastSeen,
  });

  final String displayName;
  final String camoId;
  final VoidCallback onTap;
  final VoidCallback? onCopyTap;
  final WorkspacePresenceStatus presenceStatus;
  final String? lastSeen;

  @override
  Widget build(BuildContext context) {
    final bool hasPair =
        displayName.trim().isNotEmpty && camoId.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CamoCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          child: Row(
            children: [
              WorkspaceAvatar(
                isOnline:
                    presenceStatus == WorkspacePresenceStatus.online,
              ),
              CamoSpacing.gapHorizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPair ? displayName : 'Select Pair',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CamoTypography.bodyStrong.copyWith(
                        color: CamoColors.textPrimary,
                      ),
                    ),
                    CamoSpacing.gapXs,
                    Text(
                      hasPair
                          ? camoId
                          : 'Choose a paired user to continue',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CamoTypography.label.copyWith(
                        color: CamoColors.textSecondary,
                      ),
                    ),
                    if (hasPair) ...[
                      const SizedBox(height: 4),
                      WorkspacePresenceBadge(
                        status: presenceStatus,
                        timeText: lastSeen,
                      ),
                    ],
                  ],
                ),
              ),
              CamoSpacing.gapHorizontalSm,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasPair && onCopyTap != null)
                    WorkspaceCopyButton(
                      onTap: onCopyTap!,
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: CamoColors.icon,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}