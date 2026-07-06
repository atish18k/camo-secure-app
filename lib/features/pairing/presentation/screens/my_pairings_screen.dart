// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../domain/entities/pairing_entity.dart';
import '../../domain/usecases/delete_pairing_usecase.dart';
import '../providers/accepted_pairings_provider.dart';

// ---------------------------------------------------------------------------
// My Pairings Screen
// ---------------------------------------------------------------------------

class MyPairingsScreen extends ConsumerWidget {
  const MyPairingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PairingEntity>> pairings =
        ref.watch(acceptedPairingsProvider);

    final String? currentUserUid = sl<GetCurrentUserIdUseCase>()();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pairings'),
      ),
      body: SafeArea(
        child: pairings.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unable to load pairings.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (items) {
            if (currentUserUid == null || currentUserUid.isEmpty) {
              return const Center(
                child: Text('Please login again to view pairings.'),
              );
            }

            if (items.isEmpty) {
              return const Center(
                child: Text('No active pairings.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(
                height: 12,
              ),
              itemBuilder: (context, index) {
                final PairingEntity pairing = items[index];

                final String otherCamoId =
                    pairing.requesterUid == currentUserUid
                        ? pairing.receiverCamoId
                        : pairing.requesterCamoId;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(otherCamoId),
                          subtitle: Text(
                            'Status: ${pairing.status.name.toUpperCase()}',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.link_off),
                            label: const Text('Disconnect'),
                            onPressed: () => _confirmDisconnect(
                              context: context,
                              pairing: pairing,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDisconnect({
    required BuildContext context,
    required PairingEntity pairing,
  }) async {
    final bool? shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (context) {
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