// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import '../../domain/entities/pairing_entity.dart';
import '../providers/pair_request_provider.dart';
import '../providers/pending_pair_requests_provider.dart';

// ---------------------------------------------------------------------------
// Pending Pair Requests Screen
// ---------------------------------------------------------------------------

class PendingPairRequestsScreen extends ConsumerWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PendingPairRequestsScreen({
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PairingEntity>> requests =
        ref.watch(pendingPairRequestsProvider);

    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pending Requests'),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: requests.when(
            loading: _buildLoading,
            error: _buildError,
            data: (List<PairingEntity> items) {
              if (items.isEmpty) {
                return _buildEmptyState();
              }

              return _buildRequestList(
                items: items,
                ref: ref,
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
    return const Center(
      child: Text('Unable to load pending requests.'),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No pending pair requests.'),
    );
  }

  Widget _buildRequestList({
    required List<PairingEntity> items,
    required WidgetRef ref,
  }) {
    return ListView.separated(
      padding: CamoSpacing.screen,
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) {
        return CamoSpacing.gapMd;
      },
      itemBuilder: (BuildContext context, int index) {
        final PairingEntity pairing = items[index];

        return _PendingRequestCard(
          pairing: pairing,
          onReject: () {
            ref.read(pairRequestProvider.notifier).rejectPairRequest(
                  pairing.id,
                );
          },
          onAccept: () {
            ref.read(pairRequestProvider.notifier).acceptPairRequest(
                  pairing.id,
                );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _PendingRequestCard extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _PendingRequestCard({
    required this.pairing,
    required this.onReject,
    required this.onAccept,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final PairingEntity pairing;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pairing.requesterCamoId,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          CamoSpacing.gapXs,
          Text(
            'Wants to pair with you',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CamoColors.textSecondary,
                ),
          ),
          CamoSpacing.gapMd,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
              ),
              CamoSpacing.gapHorizontalMd,
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}