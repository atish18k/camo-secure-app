// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/pairing_entity.dart';
import '../providers/pairing_hub_controller.dart';
import '../providers/pairing_hub_state.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PairingHubScreen extends ConsumerWidget {
  const PairingHubScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PairingHubState state = ref.watch(pairingHubControllerProvider);
    final PairingHubController controller =
        ref.read(pairingHubControllerProvider.notifier);

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
                  state: state,
                  controller: controller,
                ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required PairingHubState state,
    required PairingHubController controller,
  }) {
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: CamoSpacing.screen,
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: CamoSpacing.screen,
          child: Column(
            children: [
              _SearchField(
                onChanged: controller.updateSearchQuery,
              ),
              CamoSpacing.gapMd,
              _PairingHubTabs(
                state: state,
                onChanged: controller.selectTab,
              ),
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
        return _PairingList(
          items: _filterPairings(
            items: state.receivedRequests,
            query: state.searchQuery,
          ),
          emptyMessage: 'No pair requests received.',
          builder: (PairingEntity pairing) {
            return _PairingCard(
              pairing: pairing,
              mode: _PairingCardMode.received,
              onPrimaryTap: () => _confirmAction(
                context: context,
                title: 'Accept Pair Request?',
                message: 'This CAMO identity will be added to your paired users.',
                confirmLabel: 'Accept',
                onConfirmed: () async {
                  await controller.acceptRequest(pairing.id);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pairing successful.'),
                    ),
                  );
                },
              ),
              onSecondaryTap: () => _confirmAction(
                context: context,
                title: 'Reject Pair Request?',
                message: 'This pair request will be rejected.',
                confirmLabel: 'Reject',
                onConfirmed: () => controller.rejectRequest(pairing.id),
              ),
            );
          },
        );

      case PairingHubTab.sent:
        return _PairingList(
          items: _filterPairings(
            items: state.sentRequests,
            query: state.searchQuery,
          ),
          emptyMessage: 'No sent requests.',
          builder: (PairingEntity pairing) {
            return _PairingCard(
              pairing: pairing,
              mode: _PairingCardMode.sent,
              onPrimaryTap: () => _handleSentPrimaryAction(
                context: context,
                controller: controller,
                pairing: pairing,
              ),
              onSecondaryTap: pairing.status == PairingStatus.accepted
                  ? () => _confirmAction(
                        context: context,
                        title: 'Disconnect Pairing?',
                        message: 'This CAMO pairing will be removed.',
                        confirmLabel: 'Disconnect',
                        onConfirmed: () =>
                            controller.disconnectPairing(pairing.id),
                      )
                  : null,
            );
          },
        );

      case PairingHubTab.paired:
        return _PairingList(
          items: _filterPairings(
            items: state.pairedUsers,
            query: state.searchQuery,
          ),
          emptyMessage: 'No active pairings.',
          builder: (PairingEntity pairing) {
            return _PairingCard(
              pairing: pairing,
              mode: _PairingCardMode.paired,
              onPrimaryTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.home,
                  arguments: pairing,
                );
              },
              onSecondaryTap: () => _confirmAction(
                context: context,
                title: 'Disconnect Pairing?',
                message: 'This CAMO pairing will be removed.',
                confirmLabel: 'Disconnect',
                onConfirmed: () => controller.disconnectPairing(pairing.id),
              ),
            );
          },
        );
    }
  }

  Future<void> _handleSentPrimaryAction({
    required BuildContext context,
    required PairingHubController controller,
    required PairingEntity pairing,
  }) async {
    switch (pairing.status) {
      case PairingStatus.pending:
        return _confirmAction(
          context: context,
          title: 'Cancel Pair Request?',
          message: 'This pending pair request will be cancelled.',
          confirmLabel: 'Cancel',
          onConfirmed: () => controller.cancelRequest(pairing.id),
        );

      case PairingStatus.accepted:
        Navigator.pushNamed(
          context,
          AppRoutes.home,
          arguments: pairing,
        );
        return;

      case PairingStatus.rejected:
      case PairingStatus.cancelled:
      case PairingStatus.expired:
      case PairingStatus.blocked:
        return _confirmAction(
          context: context,
          title: 'Delete Request?',
          message: 'This request will be permanently deleted.',
          confirmLabel: 'Delete',
          onConfirmed: () => controller.deleteRequest(pairing.id),
        );
    }
  }

  Future<void> _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirmed,
  }) async {
    final bool? shouldContinue = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) {
      return;
    }

    await onConfirmed();
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

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search Name / CAMO ID',
        prefixIcon: const Icon(Icons.search_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabs
// ---------------------------------------------------------------------------

class _PairingHubTabs extends StatelessWidget {
  const _PairingHubTabs({
    required this.state,
    required this.onChanged,
  });

  final PairingHubState state;
  final ValueChanged<PairingHubTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PairingHubTab>(
      segments: [
        ButtonSegment<PairingHubTab>(
          value: PairingHubTab.received,
          icon: const Icon(Icons.inbox_outlined),
          label: Text('Received (${state.receivedCount})'),
        ),
        ButtonSegment<PairingHubTab>(
          value: PairingHubTab.sent,
          icon: const Icon(Icons.outbox_outlined),
          label: Text('Sent (${state.sentCount})'),
        ),
        ButtonSegment<PairingHubTab>(
          value: PairingHubTab.paired,
          icon: const Icon(Icons.people_outline_rounded),
          label: Text('Paired (${state.pairedCount})'),
        ),
      ],
      selected: <PairingHubTab>{state.selectedTab},
      onSelectionChanged: (Set<PairingHubTab> selected) {
        onChanged(selected.first);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

class _PairingList extends StatelessWidget {
  const _PairingList({
    required this.items,
    required this.emptyMessage,
    required this.builder,
  });

  final List<PairingEntity> items;
  final String emptyMessage;
  final Widget Function(PairingEntity pairing) builder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: CamoSpacing.screen,
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: CamoSpacing.screen,
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) {
        return CamoSpacing.gapMd;
      },
      itemBuilder: (BuildContext context, int index) {
        return builder(items[index]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

enum _PairingCardMode {
  received,
  sent,
  paired,
}

class _PairingCard extends StatelessWidget {
  const _PairingCard({
    required this.pairing,
    required this.mode,
    required this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final PairingEntity pairing;
  final _PairingCardMode mode;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserEntity?>(
      future: _loadRemoteUser(),
      builder: (BuildContext context, AsyncSnapshot<UserEntity?> snapshot) {
        final UserEntity? user = snapshot.data;
        final String displayName = _resolveDisplayName(user);
        final String camoId = _remoteCamoId();

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
                title: Text(displayName),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(camoId),
                    ),
                    IconButton(
                      tooltip: 'Copy CAMO ID',
                      onPressed: () => _copyCamoId(
                        context: context,
                        camoId: camoId,
                      ),
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusLine(
                text: _statusText,
                color: _statusColor,
              ),
              CamoSpacing.gapSm,
              _buildActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActions() {
    switch (mode) {
      case _PairingCardMode.received:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onPrimaryTap,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Accept'),
              ),
            ),
            CamoSpacing.gapHorizontalSm,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSecondaryTap,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject'),
              ),
            ),
          ],
        );

      case _PairingCardMode.sent:
        if (pairing.status == PairingStatus.accepted) {
          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPrimaryTap,
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: const Text('Encode / Decode'),
                ),
              ),
              CamoSpacing.gapHorizontalSm,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSecondaryTap,
                  icon: const Icon(Icons.link_off_rounded),
                  label: const Text('Disconnect'),
                ),
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onPrimaryTap,
            icon: Icon(_sentPrimaryIcon),
            label: Text(_sentPrimaryLabel),
          ),
        );

      case _PairingCardMode.paired:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onPrimaryTap,
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Encode / Decode'),
              ),
            ),
            CamoSpacing.gapHorizontalSm,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSecondaryTap,
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('Disconnect'),
              ),
            ),
          ],
        );
    }
  }

  Future<UserEntity?> _loadRemoteUser() {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    final String remoteUid = currentUserId == pairing.requesterUid
        ? pairing.receiverUid
        : pairing.requesterUid;

    return sl<ProfileRepository>().getUser(remoteUid);
  }

  String _remoteCamoId() {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    if (currentUserId == pairing.requesterUid) {
      return pairing.receiverCamoId;
    }

    return pairing.requesterCamoId;
  }

  String _resolveDisplayName(UserEntity? user) {
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

  Future<void> _copyCamoId({
    required BuildContext context,
    required String camoId,
  }) async {
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

  String get _statusText {
    switch (mode) {
      case _PairingCardMode.received:
        return 'Received • ${_formatDate(pairing.createdAt)}';

      case _PairingCardMode.sent:
        return '${pairing.status.name.toUpperCase()} • ${_formatDate(pairing.updatedAt)}';

      case _PairingCardMode.paired:
        final DateTime connectedDate = pairing.acceptedAt ?? pairing.updatedAt;
        return 'Connected • ${_formatDate(connectedDate)}';
    }
  }

  Color get _statusColor {
    switch (pairing.status) {
      case PairingStatus.accepted:
        return CamoColors.success;

      case PairingStatus.pending:
        return CamoColors.warning;

      case PairingStatus.rejected:
      case PairingStatus.blocked:
      case PairingStatus.cancelled:
      case PairingStatus.expired:
        return CamoColors.textSecondary;
    }
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

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Status Line
// ---------------------------------------------------------------------------

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
          ),
    );
  }
}