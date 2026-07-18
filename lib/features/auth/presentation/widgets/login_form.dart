import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_state.dart';
import 'email_field.dart';
import 'login_button.dart';
import 'password_field.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authControllerProvider);
    final bool isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authControllerProvider, _handleAuthStateChange);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailField(controller: _emailController),
          CamoSpacing.gapLg,
          PasswordField(controller: _passwordController),
          CamoSpacing.gapSm,
          _buildForgotPasswordButton(isLoading),
          CamoSpacing.gapLg,
          LoginButton(
            isLoading: isLoading,
            onPressed: isLoading ? null : _login,
          ),
          CamoSpacing.gapSm,
          TextButton.icon(
            onPressed: isLoading
                ? null
                : () =>
                      Navigator.pushNamed(context, AppRoutes.deviceEligibility),
            icon: const Icon(Icons.phonelink_lock_outlined),
            label: const Text('Check device support before purchase'),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton(bool isLoading) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading ? null : _onForgotPassword,
        style: TextButton.styleFrom(
          foregroundColor: CamoColors.textSecondary,
          textStyle: CamoTypography.label,
        ),
        child: const Text('Forgot Password?'),
      ),
    );
  }

  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    if (!mounted) return;

    switch (next.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
      case AuthStatus.unauthenticated:
        return;

      case AuthStatus.authenticated:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        return;

      case AuthStatus.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure?.message ?? 'Login failed.')),
        );
        return;
    }
  }

  Future<void> _login() async {
    final FormState? form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password will be available soon.')),
    );
  }
}
