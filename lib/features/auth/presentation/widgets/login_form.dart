import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    debugPrint('UI: Login tapped');

    if (!_formKey.currentState!.validate()) {
      debugPrint('UI: Form validation failed');
      return;
    }

    debugPrint('UI: Calling AuthController');

    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    debugPrint('UI: AuthController completed');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      debugPrint('UI: Auth status changed -> ${next.status}');

      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }

      if (next.status == AuthStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure?.message ?? 'Login failed'),
          ),
        );
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailField(controller: _emailController),
          const SizedBox(height: 16),
          PasswordField(controller: _passwordController),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : () {},
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 16),
          LoginButton(
            isLoading: isLoading,
            onPressed: isLoading ? null : _login,
          ),
        ],
      ),
    );
  }
}