import 'package:flutter/material.dart';

import 'email_field.dart';
import 'login_button.dart';
import 'password_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    // Firebase login will be added later.
    debugPrint('Login button pressed');
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                // Forgot Password (later)
              },
              child: const Text('Forgot Password?'),
            ),
          ),

          const SizedBox(height: 16),

          LoginButton(isLoading: _isLoading, onPressed: _login),
        ],
      ),
    );
  }
}
