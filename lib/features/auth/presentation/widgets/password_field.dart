// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

class PasswordField extends StatefulWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final TextEditingController controller;
  final String? Function(String?)? validator;

  // ---------------------------------------------------------------------------
  // Create State
  // ---------------------------------------------------------------------------

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  bool _obscureText = true;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(
          CamoIcons.password,
          color: CamoColors.icon,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? CamoIcons.visibilityOff
                : CamoIcons.visibility,
            color: CamoColors.icon,
          ),
          onPressed: _toggleVisibility,
        ),
      ),
      validator: widget.validator,
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}