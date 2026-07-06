// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pairing_entity.dart';
import '../providers/pair_request_provider.dart';
import '../providers/pending_pair_requests_provider.dart';

// ---------------------------------------------------------------------------
// Pending Pair Requests Screen
// ---------------------------------------------------------------------------

class PendingPairRequestsScreen extends ConsumerWidget {
  const PendingPairRequestsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PairingEntity>> requests =
        ref.watch(pendingPairRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
      ),
      body: SafeArea(
        child: requests.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => const Center(
            child: Text('Unable to load pending requests.'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('No pending pair requests.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final PairingEntity pairing = items[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pairing.requesterCamoId,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        const Text('Wants to pair with you'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(pairRequestProvider.notifier)
                                      .rejectPairRequest(pairing.id);
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  ref
                                      .read(pairRequestProvider.notifier)
                                      .acceptPairRequest(pairing.id);
                                },
                                child: const Text('Accept'),
                              ),
                            ),
                          ],
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
}