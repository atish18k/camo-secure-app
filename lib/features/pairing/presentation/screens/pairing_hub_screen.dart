import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../providers/incoming_pair_requests_provider.dart';

class PairingHubScreen extends ConsumerWidget {
  const PairingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingRequests = ref.watch(incomingPairRequestsProvider);

    final incomingCount = incomingRequests.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pairing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Send / Join Pair'),
              subtitle: const Text('Enter CAMO ID and send a pair request.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.pairRequest,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Incoming Pair Requests'),
              subtitle: Text(
                incomingCount == 0
                    ? 'No pending requests.'
                    : '$incomingCount pending request(s).',
              ),
              trailing: incomingCount > 0
                  ? CircleAvatar(
                      radius: 14,
                      child: Text(
                        incomingCount.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.incomingPairRequests,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}