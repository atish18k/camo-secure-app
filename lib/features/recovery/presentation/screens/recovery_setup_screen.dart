import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/button/camo_button.dart';
import '../../../../shared/widgets/cards/camo_card.dart';
import '../models/camo_recovery_view_state.dart';

class RecoverySetupScreen extends StatefulWidget {
  const RecoverySetupScreen({super.key});

  @override
  State<RecoverySetupScreen> createState() => _RecoverySetupScreenState();
}

class _RecoverySetupScreenState extends State<RecoverySetupScreen> {
  static const CamoRecoveryViewState _state = CamoRecoveryViewState.unbound();
  bool _consentAcknowledged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        backgroundColor: CamoColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Recovery setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CamoSpacing.screen,
          child: ResponsiveContainer(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protect access without exposing your keys',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                CamoSpacing.gapSm,
                Text(
                  'CAMO recovery may use only encrypted backup material. '
                  'Private keys and recovery secrets are never shown or exported.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                CamoSpacing.gapLg,
                CamoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encrypted backup',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      CamoSpacing.gapMd,
                      _StatusRow(
                        label: 'Backup service',
                        value: _state.encryptedBackupAvailable
                            ? 'Available'
                            : 'Unavailable',
                      ),
                      CamoSpacing.gapSm,
                      _StatusRow(
                        label: 'Cloud provider',
                        value: _state.providerConnected
                            ? 'Connected'
                            : 'Not connected',
                      ),
                      CamoSpacing.gapSm,
                      _StatusRow(
                        label: 'Recovery verification',
                        value: _state.recoveryVerified
                            ? 'Verified'
                            : 'Not verified',
                      ),
                      CamoSpacing.gapMd,
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _consentAcknowledged,
                          onChanged: (value) => setState(
                            () => _consentAcknowledged = value ?? false,
                          ),
                          title: const Text(
                            'I consent to encrypted backup when an approved provider becomes available.',
                          ),
                          subtitle: const Text(
                            'Consent does not create a backup or activate recovery.',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      CamoSpacing.gapSm,
                      const CamoButton.primary(
                        text: 'Encrypted backup unavailable',
                        onPressed: null,
                        icon: Icons.cloud_off_outlined,
                      ),
                    ],
                  ),
                ),
                CamoSpacing.gapLg,
                CamoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device-loss recovery',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      CamoSpacing.gapMd,
                      _StatusRow(
                        label: 'Recovery approval',
                        value: _state.deviceLossRecoveryAvailable
                            ? 'Available'
                            : 'Unavailable',
                      ),
                      CamoSpacing.gapSm,
                      _StatusRow(
                        label: 'Device migration',
                        value: _state.migrationAvailable
                            ? 'Available'
                            : 'Unavailable',
                      ),
                      CamoSpacing.gapMd,
                      Text(
                        'A new device cannot approve itself. Recovery and migration '
                        'require separate server authorization and exact-device checks.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      CamoSpacing.gapMd,
                      const CamoButton.outlined(
                        text: 'Device recovery unavailable',
                        onPressed: null,
                        icon: Icons.phonelink_lock_outlined,
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

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
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
