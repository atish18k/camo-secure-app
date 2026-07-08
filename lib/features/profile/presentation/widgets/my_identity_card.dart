// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../providers/my_identity_controller.dart';
import '../providers/my_identity_state.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class MyIdentityCard extends ConsumerWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const MyIdentityCard({
    super.key,
    required this.onQrTap,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final VoidCallback onQrTap;

  static const Duration _animationDuration = Duration(milliseconds: 280);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyIdentityState state = ref.watch(myIdentityControllerProvider);
    final MyIdentityController controller =
        ref.read(myIdentityControllerProvider.notifier);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.person_outline_rounded,
          size: 52,
          color: CamoColors.primary,
        ),
        CamoSpacing.gapMd,
        Text(
          state.displayName.trim().isEmpty ? 'CAMO User' : state.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: CamoTypography.cardTitle.copyWith(
            color: CamoColors.textPrimary,
          ),
        ),
        CamoSpacing.gapLg,
        _buildIdentityRow(
          context: context,
          state: state,
          controller: controller,
        ),
        CamoSpacing.gapLg,
        OutlinedButton.icon(
          onPressed: onQrTap,
          icon: const Icon(Icons.qr_code_2_outlined),
          label: const Text('QR Code'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildIdentityRow({
    required BuildContext context,
    required MyIdentityState state,
    required MyIdentityController controller,
  }) {
    return Row(
      children: [
        Expanded(
          child: _IdentityActionButton(
            label: state.isVisible ? 'Hide' : 'Reveal',
            onTap: controller.toggleVisibility,
          ),
        ),
        const SizedBox(width: CamoSpacing.sm),
        Expanded(
          flex: 2,
          child: AnimatedSwitcher(
            duration: _animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final Animation<double> scale = Tween<double>(
                begin: 0.96,
                end: 1,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: Text(
              state.maskedCamoId,
              key: ValueKey<String>(state.maskedCamoId),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: CamoTypography.bodyStrong.copyWith(
                color: state.isVisible
                    ? CamoColors.textPrimary
                    : CamoColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(width: CamoSpacing.sm),
        Expanded(
          child: _IdentityActionButton(
            label: state.isCopied ? 'Copied' : 'Copy',
            onTap: () => _copyCamoId(
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
    required MyIdentityController controller,
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
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _IdentityActionButton extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _IdentityActionButton({
    required this.label,
    required this.onTap,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String label;
  final VoidCallback onTap;

  static const Duration _animationDuration = Duration(milliseconds: 250);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: AnimatedSwitcher(
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}