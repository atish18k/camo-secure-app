import 'package:flutter/material.dart';

import '../../../../core/crypto/trust/camo_local_device_trust_guard.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../../../core/theme/camo_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// Allows authentication to complete while fail-closing every protected CAMO
/// feature until this exact local device is remotely approved and its public
/// key matches the locally held key pair.
class CamoDeviceApprovalGate extends StatefulWidget {
  const CamoDeviceApprovalGate({required this.child, super.key});

  final Widget child;

  @override
  State<CamoDeviceApprovalGate> createState() => _CamoDeviceApprovalGateState();
}

class _CamoDeviceApprovalGateState extends State<CamoDeviceApprovalGate> {
  late Future<void> _verification;

  @override
  void initState() {
    super.initState();
    _verification = _verify();
  }

  Future<void> _verify() => sl<CamoLocalDeviceTrustGuard>().ensureTrusted();

  void _retry() {
    setState(() {
      _verification = _verify();
    });
  }

  Future<void> _logout() async {
    final result = await sl<AuthRepository>().signOut();
    if (!mounted) return;
    switch (result) {
      case app_result.Success<void>():
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      case app_result.Error<void>():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _verification,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ApprovalStatusScreen.verifying();
        }
        if (snapshot.hasError) {
          return _ApprovalStatusScreen.restricted(
            onRetry: _retry,
            onLogout: _logout,
          );
        }
        return widget.child;
      },
    );
  }
}

class _ApprovalStatusScreen extends StatelessWidget {
  const _ApprovalStatusScreen.verifying()
    : isVerifying = true,
      onRetry = null,
      onLogout = null;

  const _ApprovalStatusScreen.restricted({
    required this.onRetry,
    required this.onLogout,
  }) : isVerifying = false;

  final bool isVerifying;
  final VoidCallback? onRetry;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamoColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    isVerifying
                        ? Icons.verified_user_outlined
                        : Icons.lock_clock_outlined,
                    size: 72,
                    color: CamoColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isVerifying
                        ? 'Verifying this device'
                        : 'Device access restricted',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVerifying
                        ? 'CAMO is validating the approved device record and local key binding.'
                        : 'No CAMO function is available until this exact device and its local public-key binding are remotely approved. Pending, rejected, revoked, missing, mismatched, and unavailable states remain blocked.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (isVerifying)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Check approval again'),
                    ),
                    const SizedBox(height: 12),
                    const OutlinedButton(
                      onPressed: null,
                      child: Text('Recovery approval unavailable'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => onLogout?.call(),
                      child: const Text('Logout'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
