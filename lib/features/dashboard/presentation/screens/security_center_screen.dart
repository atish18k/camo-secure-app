import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../widgets/security_center_card.dart';

class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Security Center'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CamoSpacing.screen,
          child: ResponsiveContainer(child: const SecurityCenterCard()),
        ),
      ),
    );
  }
}
