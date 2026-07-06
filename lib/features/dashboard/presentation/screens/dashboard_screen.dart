// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../pairing/domain/services/qr_payload_parser.dart';
import '../../../pairing/presentation/providers/pair_request_provider.dart';
import '../../../pairing/presentation/providers/pair_request_state.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_state.dart';
import '../widgets/identity_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/recent_activity_card.dart';
import '../widgets/security_center_card.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardState state = ref.watch(dashboardProvider);

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
                  next.failure?.message ?? 'Unable to send pair request.',
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
      appBar: _buildAppBar(),
      body: _buildBody(
        context: context,
        ref: ref,
        state: state,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('CAMO'),
      centerTitle: false,
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required DashboardState state,
  }) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CamoSpacing.lg),
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentityCard(state),
              const SizedBox(height: CamoSpacing.lg),
              const SecurityCenterCard(),
              const SizedBox(height: CamoSpacing.lg),
              _buildQuickActions(
                context: context,
                ref: ref,
              ),
              const SizedBox(height: CamoSpacing.lg),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard(DashboardState state) {
    return IdentityCard(
      displayName: state.displayName,
      camoId: state.camoId,
      isPaired: state.isPaired,
    );
  }

  Widget _buildQuickActions({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: CamoSpacing.md,
      mainAxisSpacing: CamoSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        QuickActionTile(
          title: 'Pair Request',
          subtitle: 'Send CAMO request',
          icon: Icons.person_add_alt_1_outlined,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.pairRequest,
          ),
        ),
        QuickActionTile(
          title: 'Pending',
          subtitle: 'Accept or reject',
          icon: Icons.mark_email_unread_outlined,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.pendingPairRequests,
          ),
        ),
        QuickActionTile(
          title: 'My Pairings',
          subtitle: 'Trusted CAMO users',
          icon: Icons.people_alt_outlined,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.myPairings,
          ),
        ),
        QuickActionTile(
          title: 'Scan QR',
          subtitle: 'Scan CAMO QR',
          icon: Icons.qr_code_scanner,
          onTap: () async {
            final Object? result = await Navigator.pushNamed(
              context,
              AppRoutes.qrScanner,
            );

            if (result is! QrPayload) {
              return;
            }

            ref
                .read(pairRequestProvider.notifier)
                .createPairRequestByCamoId(result.camoId);
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return const RecentActivityCard();
  }
}