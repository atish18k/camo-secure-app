import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../policy/domain/entities/camo_device_support_acceptance.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  CamoDeviceSupportAcceptance? _acceptance;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = ref.watch(authControllerProvider);
    final bool loading = state.status == AuthStatus.loading;
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next.status == AuthStatus.awaitingEmailVerification) {
        Navigator.pushReplacementNamed(context, AppRoutes.verifyEmail);
      } else if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure?.message ?? 'Registration failed.'),
          ),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: CamoSpacing.screen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                      ),
                      validator: _required,
                    ),
                    CamoSpacing.gapLg,
                    EmailField(controller: _email, validator: _emailValidator),
                    CamoSpacing.gapLg,
                    PasswordField(
                      controller: _password,
                      validator: _passwordValidator,
                    ),
                    CamoSpacing.gapLg,
                    TextFormField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      validator: (value) => value == _password.text
                          ? null
                          : 'Passwords do not match.',
                    ),
                    CamoSpacing.gapLg,
                    OutlinedButton.icon(
                      onPressed: loading ? null : _checkDevice,
                      icon: const Icon(Icons.phonelink_lock_outlined),
                      label: Text(
                        _acceptance == null
                            ? 'Check and accept device support'
                            : 'Device support accepted',
                      ),
                    ),
                    CamoSpacing.gapLg,
                    FilledButton(
                      onPressed: loading || _acceptance == null
                          ? null
                          : _submit,
                      child: Text(loading ? 'Creatingâ€¦' : 'Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;
  String? _emailValidator(String? value) =>
      value != null && value.contains('@') ? null : 'Enter a valid email.';
  String? _passwordValidator(String? value) =>
      value != null && value.length >= 8 ? null : 'Use at least 8 characters.';

  Future<void> _checkDevice() async {
    final Object? result = await Navigator.pushNamed(
      context,
      AppRoutes.deviceEligibility,
    );
    if (result is CamoDeviceSupportAcceptance && mounted) {
      setState(() => _acceptance = result);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _acceptance == null) {
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .createAccount(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
          acceptance: _acceptance!,
        );
  }
}
