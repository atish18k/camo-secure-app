import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState state = ref.watch(authControllerProvider);
    final bool loading = state.status == AuthStatus.loading;
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.passkeySetup);
      } else if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure?.message ?? 'Verification failed.'),
          ),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: CamoSpacing.screen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_read_outlined, size: 64),
                  CamoSpacing.gapLg,
                  const Text(
                    'Verify your email before CAMO registers this device.',
                    textAlign: TextAlign.center,
                  ),
                  CamoSpacing.gapLg,
                  FilledButton(
                    onPressed: loading
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .completeEmailVerification(),
                    child: Text(
                      loading ? 'Checkingâ€¦' : 'I verified my email',
                    ),
                  ),
                  CamoSpacing.gapSm,
                  TextButton(
                    onPressed: loading
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .resendEmailVerification(),
                    child: const Text('Resend verification email'),
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
