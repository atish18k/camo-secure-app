// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
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

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(
        context: context,
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
              _buildQuickActions(context),
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

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: CamoSpacing.md,
      mainAxisSpacing: CamoSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        QuickActionTile(
          title: 'Encode',
          subtitle: 'Secure a message',
          icon: Icons.lock_outline,
          onTap: () => _showComingSoon(
            context: context,
            featureName: 'Encode',
          ),
        ),
        QuickActionTile(
          title: 'Decode',
          subtitle: 'Open a message',
          icon: Icons.lock_open_outlined,
          onTap: () => _showComingSoon(
            context: context,
            featureName: 'Decode',
          ),
        ),
        QuickActionTile(
          title: 'Pairing',
          subtitle: 'Scan CAMO QR',
          icon: Icons.qr_code_scanner,
          onTap: () => _showComingSoon(
            context: context,
            featureName: 'Pairing Hub',
          ),
        ),
        QuickActionTile(
          title: 'Security',
          subtitle: 'Privacy settings',
          icon: Icons.shield_outlined,
          onTap: () => _showComingSoon(
            context: context,
            featureName: 'Security Center',
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return const RecentActivityCard();
  }

  void _showComingSoon({
    required BuildContext context,
    required String featureName,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName coming soon.'),
      ),
    );
  }
}