// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/widgets/avatar/camo_avatar.dart';
import '../../../../shared/widgets/badge/camo_badge.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import '../providers/identity_card_controller.dart';
import 'identity_qr_dialog.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class IdentityCard extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const IdentityCard({
    super.key,
    required this.displayName,
    required this.camoId,
    this.isPaired = false,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String displayName;
  final String camoId;
  final bool isPaired;

  static const Duration _animationDuration = Duration(milliseconds: 250);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final IdentityCardController controller = IdentityCardController(
      camoId: camoId,
    );

    return CamoCard(
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context: context,
                controller: controller,
              ),
              const SizedBox(height: CamoSpacing.lg),
              _buildStatusBadge(),
              const SizedBox(height: CamoSpacing.lg),
              _buildActions(
                context: context,
                controller: controller,
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildHeader({
    required BuildContext context,
    required IdentityCardController controller,
  }) {
    return Row(
      children: [
        CamoAvatar(
          initials: _initials,
          size: CamoAvatarSize.large,
        ),
        const SizedBox(width: CamoSpacing.md),
        Expanded(
          child: _buildIdentityInfo(
            context: context,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityInfo({
    required BuildContext context,
    required IdentityCardController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDisplayName(context),
        const SizedBox(height: 4),
        _buildCamoIdRow(
          context: context,
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildDisplayName(BuildContext context) {
    return Text(
      displayName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildCamoIdRow({
    required BuildContext context,
    required IdentityCardController controller,
  }) {
    return Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: _animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Text(
              controller.displayCamoId,
              key: ValueKey<String>(controller.displayCamoId),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CamoColors.textSecondary,
                  ),
            ),
          ),
        ),
        IconButton(
          tooltip: controller.isVisible ? 'Hide CAMO ID' : 'Reveal CAMO ID',
          onPressed: controller.toggleVisibility,
          icon: AnimatedSwitcher(
            duration: _animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Icon(
              controller.isVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey<bool>(controller.isVisible),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return CamoBadge(
      label: isPaired ? 'Paired' : 'Not Paired',
      type: isPaired ? CamoBadgeType.success : CamoBadgeType.warning,
    );
  }

  Widget _buildActions({
    required BuildContext context,
    required IdentityCardController controller,
  }) {
    return Row(
      children: [
        Expanded(
          child: _IdentityActionButton(
            icon: controller.isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            label: controller.isVisible ? 'Hide' : 'Reveal',
            onTap: controller.toggleVisibility,
          ),
        ),
        const SizedBox(width: CamoSpacing.sm),
        Expanded(
          child: _IdentityActionButton(
            icon: controller.isCopied ? Icons.check : Icons.copy_outlined,
            label: controller.isCopied ? 'Copied' : 'Copy',
            onTap: () => _copyCamoId(
              context: context,
              controller: controller,
            ),
          ),
        ),
        const SizedBox(width: CamoSpacing.sm),
        Expanded(
          child: _IdentityActionButton(
            icon: Icons.qr_code_2_outlined,
            label: 'QR',
            onTap: () => _showQr(
              context: context,
              controller: controller,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _copyCamoId({
    required BuildContext context,
    required IdentityCardController controller,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool success = await controller.copyCamoId();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success ? 'CAMO ID copied.' : 'CAMO ID is not available yet.',
        ),
      ),
    );
  }

  void _showQr({
    required BuildContext context,
    required IdentityCardController controller,
  }) {
    if (!controller.hasValidCamoId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CAMO ID is not available yet.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return IdentityQrDialog(
          camoId: controller.camoId,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String get _initials {
    final String trimmedName = displayName.trim();

    if (trimmedName.isEmpty) {
      return 'U';
    }

    final List<String> parts = trimmedName.split(RegExp(r'\s+'));

    return parts.take(2).map((String part) => part[0]).join().toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class _IdentityActionButton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _IdentityActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const Duration _animationDuration = Duration(milliseconds: 250);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: AnimatedSwitcher(
        duration: _animationDuration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Icon(
          icon,
          key: ValueKey<IconData>(icon),
          size: 18,
        ),
      ),
      label: AnimatedSwitcher(
        duration: _animationDuration,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Text(
          label,
          key: ValueKey<String>(label),
        ),
      ),
    );
  }
}