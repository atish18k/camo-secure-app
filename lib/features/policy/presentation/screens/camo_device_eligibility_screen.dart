import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../domain/entities/camo_device_support_acceptance.dart';

class CamoDeviceEligibilityResult {
  const CamoDeviceEligibilityResult({
    required this.level,
    required this.platformLabel,
    required this.hardwareBackingConfirmed,
    required this.explanation,
  });
  final CamoDeviceSupportLevel level;
  final String platformLabel;
  final bool hardwareBackingConfirmed;
  final String explanation;
}

class CamoDeviceEligibilityScreen extends StatefulWidget {
  const CamoDeviceEligibilityScreen({super.key});
  @override
  State<CamoDeviceEligibilityScreen> createState() =>
      _CamoDeviceEligibilityScreenState();
}

class _CamoDeviceEligibilityScreenState
    extends State<CamoDeviceEligibilityScreen> {
  late final CamoDeviceEligibilityResult _result = _assessConservatively();
  bool _limitedAccepted = false;

  CamoDeviceEligibilityResult _assessConservatively() {
    if (kIsWeb) {
      return const CamoDeviceEligibilityResult(
        level: CamoDeviceSupportLevel.limited,
        platformLabel: 'Web browser',
        hardwareBackingConfirmed: false,
        explanation:
            'CAMO can run in this browser, but hardware-backed local key protection cannot be confirmed before secure device enrollment.',
      );
    }
    final String platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
    if (defaultTargetPlatform == TargetPlatform.fuchsia) {
      return CamoDeviceEligibilityResult(
        level: CamoDeviceSupportLevel.unsupported,
        platformLabel: platform,
        hardwareBackingConfirmed: false,
        explanation: 'This platform is not currently supported by CAMO.',
      );
    }
    return CamoDeviceEligibilityResult(
      level: CamoDeviceSupportLevel.limited,
      platformLabel: platform,
      hardwareBackingConfirmed: false,
      explanation:
          'Basic compatibility is available. Hardware-backed local key protection will be verified during secure device enrollment and is not claimed at this stage.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool unsupported =
        _result.level == CamoDeviceSupportLevel.unsupported;
    final bool limited = _result.level == CamoDeviceSupportLevel.limited;
    final bool mayContinue = !unsupported && (!limited || _limitedAccepted);
    final String status = switch (_result.level) {
      CamoDeviceSupportLevel.fullySupported => 'Fully Supported',
      CamoDeviceSupportLevel.limited => 'Limited Support',
      CamoDeviceSupportLevel.unsupported => 'Unsupported',
    };
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(title: const Text('Device support')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: CamoSpacing.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.phonelink_lock_outlined, size: 64),
                  CamoSpacing.gapLg,
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  CamoSpacing.gapSm,
                  Text(_result.platformLabel, textAlign: TextAlign.center),
                  CamoSpacing.gapLg,
                  Text(_result.explanation),
                  CamoSpacing.gapMd,
                  Text(
                    _result.hardwareBackingConfirmed
                        ? 'Hardware-backed key protection: confirmed'
                        : 'Hardware-backed key protection: not yet confirmed',
                  ),
                  if (limited) ...[
                    CamoSpacing.gapLg,
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _limitedAccepted,
                      onChanged: (value) =>
                          setState(() => _limitedAccepted = value ?? false),
                      title: const Text(
                        'I understand that local key protection may not be hardware-backed on this device.',
                      ),
                    ),
                  ],
                  CamoSpacing.gapLg,
                  FilledButton(
                    onPressed: mayContinue
                        ? () => Navigator.pop(
                            context,
                            CamoDeviceSupportAcceptance(
                              supportLevel: _result.level,
                              platformLabel: _result.platformLabel,
                              hardwareBackingConfirmed:
                                  _result.hardwareBackingConfirmed,
                              limitedRiskAccepted: !limited || _limitedAccepted,
                            ),
                          )
                        : null,
                    child: Text(
                      unsupported
                          ? 'Purchase activation unavailable'
                          : 'Accept device support result',
                    ),
                  ),
                  CamoSpacing.gapSm,
                  const Text(
                    'Final eligibility is rechecked during enrollment. Exact-device approval remains mandatory for every CAMO function.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
