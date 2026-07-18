import 'package:flutter/material.dart';

import '../../../../core/licensing/domain/entities/camo_license_status.dart';
import '../../../../core/licensing/domain/entities/camo_subscription_status.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/button/camo_button.dart';
import '../models/camo_subscription_view_state.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({
    super.key,
    this.state = const CamoSubscriptionViewState.unavailable(),
  });

  final CamoSubscriptionViewState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(title: const Text('Subscription')),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: SingleChildScrollView(
            padding: CamoSpacing.screen,
            child: state.hasDisplayableServerFacts
                ? _ServerFactsView(state: state)
                : const _UnavailableView(),
          ),
        ),
      ),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 72,
          color: CamoColors.primary,
        ),
        CamoSpacing.gapLg,
        Text(
          'Subscription status unavailable',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        CamoSpacing.gapSm,
        const Text(
          'CAMO cannot display or grant commercial access without complete server-verified subscription facts. Access remains fail-closed.',
          textAlign: TextAlign.center,
        ),
        CamoSpacing.gapLg,
        const CamoButton.outlined(
          text: 'Server refresh unavailable',
          icon: Icons.refresh,
          onPressed: null,
        ),
      ],
    );
  }
}

class _ServerFactsView extends StatelessWidget {
  const _ServerFactsView({required this.state});
  final CamoSubscriptionViewState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('CAMO Monthly', style: Theme.of(context).textTheme.headlineSmall),
        CamoSpacing.gapMd,
        _FactRow(label: 'Plan ID', value: state.planId!),
        _FactRow(
          label: 'Price',
          value: '\u20B9${state.monthlyPriceInr} / month',
        ),
        _FactRow(
          label: 'Subscription',
          value: _subscriptionLabel(state.subscriptionStatus),
        ),
        _FactRow(label: 'License', value: _licenseLabel(state.licenseStatus)),
        _FactRow(label: 'Billing', value: state.billingState!),
        _FactRow(
          label: 'Device allowance',
          value: '${state.deviceAllowance} devices',
        ),
        if (state.renewsAt != null)
          _FactRow(label: 'Renews', value: _dateLabel(state.renewsAt!)),
        if (state.expiresAt != null)
          _FactRow(label: 'Expires', value: _dateLabel(state.expiresAt!)),
        CamoSpacing.gapLg,
        const Text(
          'Displayed values are server-owned facts. Renewal and cancellation actions remain unavailable until an authorized provider workflow is bound.',
        ),
        CamoSpacing.gapLg,
        const CamoButton.primary(
          text: 'Manage subscription unavailable',
          icon: Icons.manage_accounts_outlined,
          onPressed: null,
        ),
      ],
    );
  }

  static String _subscriptionLabel(CamoSubscriptionStatus status) {
    return switch (status) {
      CamoSubscriptionStatus.unknown => 'Unknown',
      CamoSubscriptionStatus.trial => 'Trial',
      CamoSubscriptionStatus.active => 'Active',
      CamoSubscriptionStatus.gracePeriod => 'Grace period',
      CamoSubscriptionStatus.paused => 'Paused',
      CamoSubscriptionStatus.expired => 'Expired',
      CamoSubscriptionStatus.cancelled => 'Cancelled',
    };
  }

  static String _licenseLabel(CamoLicenseStatus status) {
    return switch (status) {
      CamoLicenseStatus.unknown => 'Unknown',
      CamoLicenseStatus.pending => 'Pending',
      CamoLicenseStatus.active => 'Active',
      CamoLicenseStatus.suspended => 'Suspended',
      CamoLicenseStatus.expired => 'Expired',
      CamoLicenseStatus.revoked => 'Revoked',
    };
  }

  static String _dateLabel(DateTime value) => value.toUtc().toIso8601String();
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: CamoSpacing.card,
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
