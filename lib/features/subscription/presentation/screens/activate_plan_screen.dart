import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/button/camo_button.dart';

class ActivatePlanScreen extends StatelessWidget {
  const ActivatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(title: const Text('Activate Plan')),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 680,
          child: Padding(
            padding: CamoSpacing.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  size: 72,
                  color: CamoColors.primary,
                ),
                CamoSpacing.gapLg,
                Text(
                  'Activation unavailable',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                CamoSpacing.gapSm,
                const Text(
                  'The payment-provider and server subscription authority are not bound yet. CAMO will not simulate payment success or grant access from this device.',
                  textAlign: TextAlign.center,
                ),
                CamoSpacing.gapLg,
                const Card(
                  child: Padding(
                    padding: CamoSpacing.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected plan: CAMO Monthly'),
                        SizedBox(height: 8),
                        Text('Price: \u20B9199 / month'),
                        SizedBox(height: 8),
                        Text('Status: Awaiting server integration'),
                      ],
                    ),
                  ),
                ),
                CamoSpacing.gapLg,
                const CamoButton.primary(
                  text: 'Provider verification unavailable',
                  icon: Icons.verified_user_outlined,
                  onPressed: null,
                ),
                CamoSpacing.gapSm,
                CamoButton.outlined(
                  text: 'Back to plan',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
