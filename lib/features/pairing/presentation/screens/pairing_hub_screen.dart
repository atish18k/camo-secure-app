// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/pairing_entity.dart';
import '../providers/pairing_hub_controller.dart';
import '../providers/pairing_hub_state.dart';
import '../providers/pair_request_provider.dart';
import '../providers/pair_request_state.dart';
import '../widgets/pairing_card.dart';
import '../widgets/pairing_confirm_dialog.dart';
import '../widgets/pairing_empty_state.dart';
import '../widgets/pair_request_form.dart';
import '../widgets/pairing_search_bar.dart';
import '../widgets/pairing_tabs.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PairingHubScreen extends ConsumerWidget {
  const PairingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PairingHubState state = ref.watch(pairingHubControllerProvider);
    final PairingHubController controller = ref.read(
      pairingHubControllerProvider.notifier,
    );
    final PairRequestState pairRequestState = ref.watch(pairRequestProvider);

    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pairing Hub'),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(
                  context: context,
                  ref: ref,
                  state: state,
                  controller: controller,
                  pairRequestState: pairRequestState,
                ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required WidgetRef ref,
    required PairingHubState state,
    required PairingHubController controller,
    required PairRequestState pairRequestState,
  }) {
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: CamoSpacing.screen,
          child: Text(state.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: CamoSpacing.screen,
          child: Column(
            children: [
              PairRequestForm(
                isLoading:
                    pairRequestState.status == PairRequestUiStatus.loading,
                onSubmit: (String camoId) {
                  ref
                      .read(pairRequestProvider.notifier)
                      .createPairRequestByCamoId(camoId);
                },
              ),
              CamoSpacing.gapLg,
              PairingSearchBar(onChanged: controller.updateSearchQuery),
              CamoSpacing.gapMd,
              PairingTabs(state: state, onChanged: controller.selectTab),
            ],
          ),
        ),
        Expanded(
          child: _buildSelectedTab(
            context: context,
            state: state,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedTab({
    required BuildContext context,
    required PairingHubState state,
    required PairingHubController controller,
  }) {
    switch (state.selectedTab) {
      case PairingHubTab.received:
        return _buildPairingList(
          items: _filterPairings(
            items: state.receivedRequests,
            query: state.searchQuery,
          ),
          emptyMessage: 'No pair requests received.',
          mode: PairingCardMode.received,
          controller: controller,
          context: context,
        );

      case PairingHubTab.sent:
        return _buildPairingList(
          items: _filterPairings(
            items: state.sentRequests,
            query: state.searchQuery,
          ),
          emptyMessage: 'No sent requests.',
          mode: PairingCardMode.sent,
          controller: controller,
          context: context,
        );

      case PairingHubTab.paired:
        return _buildPairingList(
          items: _filterPairings(
            items: state.pairedUsers,
            query: state.searchQuery,
          ),
          emptyMessage: 'No active pairings.',
          mode: PairingCardMode.paired,
          controller: controller,
          context: context,
        );
    }
  }

  Widget _buildPairingList({
    required BuildContext context,
    required List<PairingEntity> items,
    required String emptyMessage,
    required PairingCardMode mode,
    required PairingHubController controller,
  }) {
    if (items.isEmpty) {
      return PairingEmptyState(message: emptyMessage);
    }

    return ListView.separated(
      padding: CamoSpacing.screen,
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) {
        return CamoSpacing.gapMd;
      },
      itemBuilder: (BuildContext context, int index) {
        final PairingEntity pairing = items[index];

        return FutureBuilder<UserEntity?>(
          future: _loadRemoteUser(pairing),
          builder: (BuildContext context, AsyncSnapshot<UserEntity?> snapshot) {
            return PairingCard(
              pairing: pairing,
              mode: mode,
              displayName: resolvePairingDisplayName(snapshot.data),
              camoId: _remoteCamoId(pairing),
              onPrimaryTap: () => _handlePrimaryAction(
                context: context,
                controller: controller,
                pairing: pairing,
                mode: mode,
              ),
              onSecondaryTap: () => _handleSecondaryAction(
                context: context,
                controller: controller,
                pairing: pairing,
                mode: mode,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handlePrimaryAction({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
    required PairingCardMode mode,
  }) async {
    switch (mode) {
      case PairingCardMode.received:
        return _acceptRequest(
          context: context,
          controller: controller,
          pairing: pairing,
        );

      case PairingCardMode.sent:
        return _handleSentPrimaryAction(
          context: context,
          controller: controller,
          pairing: pairing,
        );

      case PairingCardMode.paired:
        Navigator.pushNamed(context, AppRoutes.home, arguments: pairing);
        return;
    }
  }

  Future<void> _handleSecondaryAction({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
    required PairingCardMode mode,
  }) async {
    switch (mode) {
      case PairingCardMode.received:
        return _rejectRequest(
          context: context,
          controller: controller,
          pairing: pairing,
        );

      case PairingCardMode.sent:
      case PairingCardMode.paired:
        return _disconnectPairing(
          context: context,
          controller: controller,
          pairing: pairing,
        );
    }
  }

  Future<void> _acceptRequest({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    final bool confirmed = await PairingConfirmDialog.show(
      context: context,
      title: 'Accept Pair Request?',
      message: 'This CAMO identity will be added to your paired users.',
      confirmText: 'Accept',
    );

    if (!confirmed) {
      return;
    }

    await controller.acceptRequest(pairing.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pairing successful.')));
  }

  Future<void> _rejectRequest({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    final bool confirmed = await PairingConfirmDialog.show(
      context: context,
      title: 'Reject Pair Request?',
      message: 'This pair request will be rejected.',
      confirmText: 'Reject',
    );

    if (!confirmed) {
      return;
    }

    await controller.rejectRequest(pairing.id);
  }

  Future<void> _handleSentPrimaryAction({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    switch (pairing.status) {
      case PairingStatus.pending:
        return _cancelRequest(
          context: context,
          controller: controller,
          pairing: pairing,
        );

      case PairingStatus.accepted:
        Navigator.pushNamed(context, AppRoutes.home, arguments: pairing);
        return;

      case PairingStatus.rejected:
      case PairingStatus.cancelled:
      case PairingStatus.expired:
      case PairingStatus.blocked:
        return _deleteRequest(
          context: context,
          controller: controller,
          pairing: pairing,
        );
    }
  }

  Future<void> _cancelRequest({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    final bool confirmed = await PairingConfirmDialog.show(
      context: context,
      title: 'Cancel Pair Request?',
      message: 'This pending pair request will be cancelled.',
      confirmText: 'Cancel',
    );

    if (!confirmed) {
      return;
    }

    await controller.cancelRequest(pairing.id);
  }

  Future<void> _disconnectPairing({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    final bool confirmed = await PairingConfirmDialog.show(
      context: context,
      title: 'Disconnect Pairing?',
      message: 'This CAMO pairing will be removed.',
      confirmText: 'Disconnect',
    );

    if (!confirmed) {
      return;
    }

    await controller.disconnectPairing(pairing.id);
  }

  Future<void> _deleteRequest({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    final bool confirmed = await PairingConfirmDialog.show(
      context: context,
      title: 'Delete Request?',
      message: 'This request will be permanently deleted.',
      confirmText: 'Delete',
    );

    if (!confirmed) {
      return;
    }

    await controller.deleteRequest(pairing.id);
  }

  Future<UserEntity?> _loadRemoteUser(PairingEntity pairing) {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    final String remoteUid = currentUserId == pairing.requesterUid
        ? pairing.receiverUid
        : pairing.requesterUid;

    return sl<ProfileRepository>().getUser(remoteUid);
  }

  String _remoteCamoId(PairingEntity pairing) {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    if (currentUserId == pairing.requesterUid) {
      return pairing.receiverCamoId;
    }

    return pairing.requesterCamoId;
  }

  List<PairingEntity> _filterPairings({
    required List<PairingEntity> items,
    required String query,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return items;
    }

    return items.where((PairingEntity pairing) {
      return pairing.requesterCamoId.toLowerCase().contains(normalizedQuery) ||
          pairing.receiverCamoId.toLowerCase().contains(normalizedQuery) ||
          pairing.status.name.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}
