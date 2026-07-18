import 'package:flutter/material.dart';

import '../../../../core/crypto/trust/camo_local_device_trust_guard.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/widgets/cards/camo_card.dart';

class SecurityCenterCard extends StatefulWidget {
  const SecurityCenterCard({super.key});

  @override
  State<SecurityCenterCard> createState() => _SecurityCenterCardState();
}

class _SecurityCenterCardState extends State<SecurityCenterCard> {
  late Future<void> _verification = _verify();

  Future<void> _verify() => sl<CamoLocalDeviceTrustGuard>().ensureTrusted();

  void _refresh() => setState(() => _verification = _verify());

  @override
  Widget build(BuildContext context) {
    return CamoCard(
      child: FutureBuilder<void>(
        future: _verification,
        builder: (context, snapshot) {
          final bool checking =
              snapshot.connectionState == ConnectionState.waiting;
          final bool approved = !checking && !snapshot.hasError;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Security Center',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Recheck exact-device trust',
                    onPressed: checking ? null : _refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              CamoSpacing.gapMd,
              _SecurityStatusRow(
                label: 'Exact device',
                value: checking
                    ? 'Checking'
                    : approved
                    ? 'Approved'
                    : 'Restricted',
                ok: approved,
                checking: checking,
              ),
              CamoSpacing.gapMd,
              _SecurityStatusRow(
                label: 'Key binding',
                value: checking
                    ? 'Checking'
                    : approved
                    ? 'Matched'
                    : 'Unavailable',
                ok: approved,
                checking: checking,
              ),
              CamoSpacing.gapMd,
              _SecurityStatusRow(
                label: 'Revocation',
                value: checking
                    ? 'Checking'
                    : approved
                    ? 'Not revoked'
                    : 'Restricted',
                ok: approved,
                checking: checking,
              ),
              CamoSpacing.gapMd,
              const Tooltip(
                message:
                    'Device approval and revocation require reauthentication and server authorization.',
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text('Device management unavailable'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SecurityStatusRow extends StatelessWidget {
  const _SecurityStatusRow({
    required this.label,
    required this.value,
    required this.ok,
    required this.checking,
  });

  final String label;
  final String value;
  final bool ok;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        if (checking)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(
            ok ? Icons.verified_user_outlined : Icons.gpp_bad_outlined,
            size: 18,
            color: ok
                ? CamoColors.success
                : Theme.of(context).colorScheme.error,
          ),
        CamoSpacing.gapHorizontalSm,
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
