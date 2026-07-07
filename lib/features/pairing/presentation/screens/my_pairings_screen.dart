// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../domain/entities/pairing_entity.dart';
import '../../domain/usecases/delete_pairing_usecase.dart';
import '../providers/accepted_pairings_provider.dart';

// ---------------------------------------------------------------------------
// My Pairings Screen
// ---------------------------------------------------------------------------

class MyPairingsScreen extends ConsumerWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const MyPairingsScreen({
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PairingEntity>> pairings =
        ref.watch(acceptedPairingsProvider);

    final String? currentUserUid = sl<GetCurrentUserIdUseCase>()();

    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Pairings'),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: pairings.when(
            loading: _buildLoading,
            error: _buildError,
            data: (List<PairingEntity> items) {
              if (currentUserUid == null || currentUserUid.isEmpty) {
                return _buildLoginRequiredState();
              }

              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return _buildPairingsList(
                context: context,
                items: items,
                currentUserUid: currentUserUid,
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(
    Object error,
    StackTrace stackTrace,
  ) {
    return Center(
      child: Padding(
        padding: CamoSpacing.screen,
        child: Text(
          'Unable to load pairings.\n$error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoginRequiredState() {
    return const Center(
      child: Text('Please login again to view pairings.'),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No active pairings.'),
    );
  }

  Widget _buildPairingsList({
    required BuildContext context,
    required List<PairingEntity> items,
    required String currentUserUid,
  }) {
    return ListView.separated(
      padding: CamoSpacing.screen,
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) {
        return CamoSpacing.gapMd;
      },
      itemBuilder: (BuildContext context, int index) {
        final PairingEntity pairing = items[index];

        final String otherCamoId = pairing.requesterUid == currentUserUid
            ? pairing.receiverCamoId
            : pairing.requesterCamoId;

        return _PairingCard(
          pairing: pairing,
          otherCamoId: otherCamoId,
          onDisconnect: () => _confirmDisconnect(
            context: context,
            pairing: pairing,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _confirmDisconnect({
    required BuildContext context,
    required PairingEntity pairing,
  }) async {
    final bool? shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disconnect Pairing?'),
          content: const Text(
            'This CAMO pairing will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Disconnect'),
            ),
          ],
        );
      },
    );

    if (shouldDisconnect != true) {
      return;
    }

    try {
      await sl<DeletePairingUseCase>()(pairing.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pairing disconnected.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to disconnect pairing. $error'),
        ),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _PairingCard extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _PairingCard({
    required this.pairing,
    required this.otherCamoId,
    required this.onDisconnect,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final PairingEntity pairing;
  final String otherCamoId;
  final VoidCallback onDisconnect;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: CamoColors.background,
              child: Icon(
                CamoIcons.profile,
                color: CamoColors.primary,
              ),
            ),
            title: Text(otherCamoId),
            subtitle: Text(
              'Status: ${pairing.status.name.toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CamoColors.textSecondary,
                  ),
            ),
          ),
          CamoSpacing.gapSm,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(CamoIcons.disconnect),
              label: const Text('Disconnect'),
              onPressed: onDisconnect,
            ),
          ),
        ],
      ),
    );
  }
}