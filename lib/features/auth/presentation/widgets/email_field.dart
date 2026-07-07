// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

class EmailField extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const EmailField({
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
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [
        AutofillHints.email,
      ],
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: const Icon(
          CamoIcons.email,
          color: CamoColors.icon,
        ),
      ),
      validator: validator,
    );
  }
}