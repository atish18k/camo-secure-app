import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pair_request_controller.dart';
import '../providers/pair_request_state.dart';
import '../widgets/pair_request_form.dart';

class PairRequestScreen extends ConsumerWidget {
  const PairRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pairRequestControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Request'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _PairRequestScreenContent(state: state),
        ),
      ),
    );
  }
}

class _PairRequestScreenContent extends ConsumerWidget {
  final PairRequestState state;

  const _PairRequestScreenContent({
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = state.status == PairRequestUiStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Securely',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Send a secure pair request to another CAMO user.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        PairRequestForm(
          isLoading: isLoading,
          onSubmit: (camoId) {
            ref
                .read(pairRequestControllerProvider.notifier)
                .sendPairRequestByCamoId(camoId);
          },
        ),
        const SizedBox(height: 16),
        if (state.status == PairRequestUiStatus.sent)
          const _SuccessMessage(),
        if (state.status == PairRequestUiStatus.failure &&
            state.failure != null)
          _ErrorMessage(message: state.failure!.message),
      ],
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text('Pair request sent successfully.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }
}