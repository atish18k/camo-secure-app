import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/pair_request_status.dart';
import '../providers/incoming_pair_requests_provider.dart';

class IncomingPairRequestsScreen extends ConsumerWidget {
  const IncomingPairRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(incomingPairRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Pair Requests'),
      ),
      body: requests.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(error.toString()),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No incoming pair requests.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = items[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(request.senderUid),
                  subtitle: Text(
                    'Status: ${request.status.value}',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}