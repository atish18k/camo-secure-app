import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../data/repositories/firebase_camo_commercial_access_request_repository.dart';
import '../../domain/repositories/camo_commercial_access_request_repository.dart';

class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key, this.requestRepository});

  static const String canonicalPlanId = 'camo_monthly_inr_199';
  static const int monthlyPriceInr = 199;

  final CamoCommercialAccessRequestRepository? requestRepository;

  @override
  State<ChoosePlanScreen> createState() => _ChoosePlanScreenState();
}

class _ChoosePlanScreenState extends State<ChoosePlanScreen> {
  bool _isRequesting = false;
  bool _requestSubmitted = false;

  Future<void> _requestCommercialAccess() async {
    if (_isRequesting || _requestSubmitted) {
      return;
    }

    setState(() {
      _isRequesting = true;
    });

    try {
      final repository =
          widget.requestRepository ??
          FirebaseCamoCommercialAccessRequestRepository();
      final result = await repository.requestAccess();

      if (!mounted) {
        return;
      }

      setState(() {
        _isRequesting = false;
        _requestSubmitted = result.isPending;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Commercial access request submitted for administrator review.',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRequesting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request failed: ${error.code}'
            '${error.message == null ? '' : ' - ${error.message}'}',
          ),
        ),
      );
    } on Object {
      if (!mounted) {
        return;
      }

      setState(() {
        _isRequesting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to submit the commercial access request. Please retry.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(title: const Text('Choose Plan')),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 680,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CamoSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'CAMO Monthly',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                CamoSpacing.gapSm,
                Text(
                  '\u20B9${ChoosePlanScreen.monthlyPriceInr} / month',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                CamoSpacing.gapLg,
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(CamoSpacing.md),
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
                const Text(
                  'Submitting a request does not activate access. Only the '
                  'server-authorized administrator approval flow can create '
                  'commercial access.',
                  textAlign: TextAlign.center,
                ),
                CamoSpacing.gapMd,
                FilledButton.icon(
                  onPressed: _isRequesting || _requestSubmitted
                      ? null
                      : _requestCommercialAccess,
                  icon: _isRequesting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _requestSubmitted
                              ? Icons.hourglass_top_rounded
                              : Icons.send_rounded,
                        ),
                  label: Text(
                    _isRequesting
                        ? 'Submitting request...'
                        : _requestSubmitted
                        ? 'Request pending'
                        : 'Request commercial access',
                  ),
                ),
                CamoSpacing.gapSm,
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.planActivation),
                  child: const Text('Review activation'),
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
  const _PlanFeature(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
