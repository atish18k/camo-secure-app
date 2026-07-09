// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../domain/entities/pairing_entity.dart';
import 'pairing_action_buttons.dart';
import 'pairing_avatar.dart';
import 'pairing_presence_badge.dart';
import 'pairing_status.dart' as status_widget;

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum PairingCardMode {
  received,
  sent,
  paired,
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingCard extends StatelessWidget {
  const PairingCard({
    super.key,
    required this.pairing,
    required this.mode,
    required this.displayName,
    required this.camoId,
    required this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final PairingEntity pairing;
  final PairingCardMode mode;
  final String displayName;
  final String camoId;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          CamoSpacing.gapMd,
          _buildStatus(),
          if (mode == PairingCardMode.paired) ...[
            CamoSpacing.gapXs,
            const PairingPresenceBadge(
              status: PairPresenceStatus.activeToday,
              timeText: '10:42',
            ),
          ],
          CamoSpacing.gapMd,
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PairingAvatar(),
        CamoSpacing.gapHorizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDisplayName(),
              CamoSpacing.gapXs,
              _buildCamoId(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayName() {
    return Text(
      displayName.trim().isEmpty ? 'CAMO User' : displayName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CamoTypography.bodyStrong.copyWith(
        color: CamoColors.textPrimary,
      ),
    );
  }

  Widget _buildCamoId(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            camoId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CamoTypography.label.copyWith(
              color: CamoColors.textSecondary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Copy CAMO ID',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _copyCamoId(context),
          icon: const Icon(
            Icons.copy_rounded,
            size: 18,
            color: CamoColors.icon,
          ),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    switch (mode) {
      case PairingCardMode.received:
        return status_widget.PairingStatus.inactive(
          text: 'Received • ${_formatDate(pairing.createdAt)}',
        );

      case PairingCardMode.sent:
        return _sentStatus();

      case PairingCardMode.paired:
        final DateTime connectedDate = pairing.acceptedAt ?? pairing.updatedAt;

        return status_widget.PairingStatus.connected(
          text: 'Connected • ${_formatDate(connectedDate)}',
        );
    }
  }

  Widget _sentStatus() {
    switch (pairing.status) {
      case PairingStatus.pending:
        return status_widget.PairingStatus.pending(
          text: 'Pending • ${_formatDate(pairing.updatedAt)}',
        );

      case PairingStatus.accepted:
        return status_widget.PairingStatus.connected(
          text: 'Accepted • ${_formatDate(pairing.updatedAt)}',
        );

      case PairingStatus.rejected:
        return status_widget.PairingStatus.rejected(
          text: 'Rejected • ${_formatDate(pairing.updatedAt)}',
        );

      case PairingStatus.cancelled:
        return status_widget.PairingStatus.inactive(
          text: 'Cancelled • ${_formatDate(pairing.updatedAt)}',
        );

      case PairingStatus.expired:
        return status_widget.PairingStatus.inactive(
          text: 'Expired • ${_formatDate(pairing.updatedAt)}',
        );

      case PairingStatus.blocked:
        return status_widget.PairingStatus.rejected(
          text: 'Blocked • ${_formatDate(pairing.updatedAt)}',
        );
    }
  }

  Widget _buildActions() {
    switch (mode) {
      case PairingCardMode.received:
        return PairingActionButtons.received(
          onAcceptTap: onPrimaryTap,
          onRejectTap: onSecondaryTap,
        );

      case PairingCardMode.sent:
        if (pairing.status == PairingStatus.accepted) {
          return PairingActionButtons.workspace(
            onPrimaryTap: onPrimaryTap,
            onSecondaryTap: onSecondaryTap,
          );
        }

        return PairingActionButtons.single(
          label: _sentPrimaryLabel,
          icon: _sentPrimaryIcon,
          onPrimaryTap: onPrimaryTap,
        );

      case PairingCardMode.paired:
        return PairingActionButtons.workspace(
          onPrimaryTap: onPrimaryTap,
          onSecondaryTap: onSecondaryTap,
        );
    }
  }

  Future<void> _copyCamoId(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: camoId),
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CAMO ID copied.'),
      ),
    );
  }

  String get _sentPrimaryLabel {
    switch (pairing.status) {
      case PairingStatus.pending:
        return 'Cancel';

      case PairingStatus.accepted:
        return 'Encode / Decode';

      case PairingStatus.rejected:
      case PairingStatus.cancelled:
      case PairingStatus.expired:
      case PairingStatus.blocked:
        return 'Delete';
    }
  }

  IconData get _sentPrimaryIcon {
    switch (pairing.status) {
      case PairingStatus.pending:
        return Icons.close_rounded;

      case PairingStatus.accepted:
        return Icons.lock_outline_rounded;

      case PairingStatus.rejected:
      case PairingStatus.cancelled:
      case PairingStatus.expired:
      case PairingStatus.blocked:
        return Icons.delete_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime valueDate = DateTime(date.year, date.month, date.day);
    final Duration difference = today.difference(valueDate);

    final String time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (difference.inDays == 0) {
      return 'Today • $time';
    }

    if (difference.inDays == 1) {
      return 'Yesterday • $time';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

String resolvePairingDisplayName(UserEntity? user) {
  final String? displayName = user?.displayName?.trim();

  if (displayName != null &&
      displayName.isNotEmpty &&
      displayName != 'CAMO User') {
    return displayName;
  }

  final String email = user?.email.trim() ?? '';

  if (email.contains('@')) {
    String name = email.split('@').first;

    name = name.replaceAll('.', ' ');
    name = name.replaceAll('_', ' ');
    name = name.replaceAll('-', ' ');

    if (name.trim().isNotEmpty) {
      return name.trim();
    }
  }

  return 'CAMO User';
}