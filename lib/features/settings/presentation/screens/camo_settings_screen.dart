import 'package:flutter/material.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

class CamoSettingsScreen extends StatelessWidget {
  const CamoSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: CamoColors.background,
    appBar: AppBar(
      backgroundColor: CamoColors.background,
      surfaceTintColor: Colors.transparent,
      title: const Text('Settings'),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: CamoSpacing.screen,
        child: ResponsiveContainer(
          maxWidth: 760,
          child: CamoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App preferences',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                CamoSpacing.gapSm,
                const Text(
                  'No configurable app preferences are available yet.',
                ),
                CamoSpacing.gapSm,
                const Text(
                  'Identity remains in the header. Security and recovery remain in Security Center.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
