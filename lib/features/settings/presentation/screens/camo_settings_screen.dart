import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/button/camo_button.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

class CamoSettingsScreen extends StatelessWidget {
  const CamoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Profile, Backup and Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CamoSpacing.screen,
          child: ResponsiveContainer(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SettingsCard(
                  title: 'Profile',
                  description:
                      'Review your canonical CAMO identity and account details.',
                  child: CamoButton.outlined(
                    text: 'Open My Identity',
                    icon: Icons.badge_outlined,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.myIdentity),
                  ),
                ),
                CamoSpacing.gapLg,
                _SettingsCard(
                  title: 'Encrypted backup and recovery',
                  description:
                      'Backup and restore remain unavailable until an approved encrypted provider and server recovery authority are bound.',
                  child: CamoButton.outlined(
                    text: 'Review recovery status',
                    icon: Icons.health_and_safety_outlined,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.recoverySetup),
                  ),
                ),
                CamoSpacing.gapLg,
                const _SettingsCard(
                  title: 'Privacy controls',
                  description:
                      'CAMO never exposes raw private keys, seed phrases or clear recovery secrets.',
                  child: Column(
                    children: [
                      _SettingsStatus(
                        label: 'Backup provider',
                        value: 'Not connected',
                      ),
                      CamoSpacing.gapSm,
                      _SettingsStatus(label: 'Restore', value: 'Unavailable'),
                      CamoSpacing.gapSm,
                      _SettingsStatus(
                        label: 'Secret export',
                        value: 'Prohibited',
                      ),
                      CamoSpacing.gapMd,
                      CamoButton.primary(
                        text: 'Encrypted restore unavailable',
                        icon: Icons.cloud_off_outlined,
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.description,
    required this.child,
  });
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          CamoSpacing.gapSm,
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          CamoSpacing.gapMd,
          child,
        ],
      ),
    );
  }
}

class _SettingsStatus extends StatelessWidget {
  const _SettingsStatus({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const Icon(
          Icons.lock_outline,
          size: 18,
          color: CamoColors.textSecondary,
        ),
        CamoSpacing.gapHorizontalSm,
        Text(value),
      ],
    );
  }
}
