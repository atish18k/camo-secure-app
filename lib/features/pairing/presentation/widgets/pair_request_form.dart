// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/components/camo_id_text_field.dart';
import 'send_pair_request_button.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairRequestForm extends StatefulWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairRequestForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool isLoading;
  final ValueChanged<String> onSubmit;

  // ---------------------------------------------------------------------------
  // Create State
  // ---------------------------------------------------------------------------

  @override
  State<PairRequestForm> createState() => _PairRequestFormState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _PairRequestFormState extends State<PairRequestForm> {
  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _camoIdController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _camoIdController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CamoIdTextField(
            controller: _camoIdController,
            validator: _validateCamoId,
          ),
          CamoSpacing.gapLg,
          SendPairRequestButton(
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _submit() {
    if (widget.isLoading) {
      return;
    }

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    widget.onSubmit(_camoIdController.text.trim().toUpperCase());
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _validateCamoId(String? value) {
    final String camoId = value?.trim().toUpperCase() ?? '';

    if (camoId.isEmpty) {
      return 'CAMO ID is required.';
    }

    final bool isValid = RegExp(
      r'^CM-[A-Z0-9]{4}-[A-Z0-9]{4}$',
    ).hasMatch(camoId);

    if (!isValid) {
      return 'Enter a valid CAMO ID.';
    }

    return null;
  }
}