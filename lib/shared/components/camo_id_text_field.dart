import 'package:flutter/material.dart';

import '../../core/formatters/camo_id_input_formatter.dart';

class CamoIdTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const CamoIdTextField({
    super.key,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      textInputAction: textInputAction,
      inputFormatters: [
        CamoIdInputFormatter(),
      ],
      decoration: const InputDecoration(
        labelText: 'CAMO ID',
        hintText: 'CM-A8X4-K9P2',
        prefixIcon: Icon(Icons.badge_outlined),
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}