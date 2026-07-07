// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../providers/pair_request_provider.dart';
import '../providers/pair_request_state.dart';
import '../widgets/pair_request_form.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class PairRequestScreen extends ConsumerWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairRequestScreen({
    super.key,
  });

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PairRequestState state = ref.watch(pairRequestProvider);

    ref.listen<PairRequestState>(
      pairRequestProvider,
      (previous, next) {
        switch (next.status) {
          case PairRequestUiStatus.sent:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pair request sent successfully.'),
              ),
            );
            break;

          case PairRequestUiStatus.failure:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  next.failure?.message ??
                      'Unable to send pair request.',
                ),
              ),
            );
            break;

          default:
            break;
        }
      },
    );

    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pair Request',
        ),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Padding(
            padding: CamoSpacing.screen,
            child: PairRequestForm(
              isLoading: state.status == PairRequestUiStatus.loading,
              onSubmit: (String camoId) {
                ref
                    .read(pairRequestProvider.notifier)
                    .createPairRequestByCamoId(camoId);
              },
            ),
          ),
        ),
      ),
    );
  }
}