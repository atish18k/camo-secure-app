import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/button/camo_button.dart';

class ChoosePlanScreen extends StatelessWidget {
  const ChoosePlanScreen({super.key});

  static const String canonicalPlanId = 'camo_monthly_inr_199';
  static const int monthlyPriceInr = 199;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(title: const Text('Choose Plan')),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 680,
          child: SingleChildScrollView(
            padding: CamoSpacing.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'CAMO Monthly',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                CamoSpacing.gapSm,
                Text(
                  '\u20B9$monthlyPriceInr / month',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: CamoColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CamoSpacing.gapLg,
                const Card(
                  child: Padding(
                    padding: CamoSpacing.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PlanFeature('Online-authorized CAMO and UNCAMO'),
                        _PlanFeature('Exact-device approval enforcement'),
                        _PlanFeature('Server-owned subscription status'),
                        _PlanFeature('Camouflage add-on sold separately'),
                      ],
                    ),
                  ),
                ),
                CamoSpacing.gapLg,
                const _AuthorityNotice(),
                CamoSpacing.gapLg,
                CamoButton.primary(
                  text: 'Review activation',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.planActivation),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  const _PlanFeature(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CamoSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: CamoColors.success),
          CamoSpacing.gapHorizontalSm,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AuthorityNotice extends StatelessWidget {
  const _AuthorityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CamoSpacing.card,
      decoration: BoxDecoration(
        color: CamoColors.surface,
        border: Border.all(color: CamoColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Selecting this plan does not activate access. Activation requires verified provider confirmation and server-owned subscription and entitlement records.',
      ),
    );
  }
}
