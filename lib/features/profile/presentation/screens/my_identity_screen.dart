// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../dashboard/presentation/widgets/identity_qr_dialog.dart';
import '../providers/my_identity_controller.dart';
import '../providers/my_identity_state.dart';
import '../widgets/my_identity_card.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class MyIdentityScreen extends ConsumerWidget {
  const MyIdentityScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyIdentityState state = ref.watch(myIdentityControllerProvider);

    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        title: const Text('My Identity'),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: CamoSpacing.screen,
            child: Center(
              child: MyIdentityCard(
                onQrTap: () => _showQr(
                  context: context,
                  state: state,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQr({
    required BuildContext context,
    required MyIdentityState state,
  }) {
    if (state.camoId.trim().isEmpty ||
        state.camoId == 'Not Signed In' ||
        state.camoId == 'Profile Not Found') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CAMO ID is not available yet.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return IdentityQrDialog(
          camoId: state.camoId,
        );
      },
    );
  }
}