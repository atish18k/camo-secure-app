import 'package:flutter/material.dart';

import '../../../../shared/components/camo_id_text_field.dart';
import 'send_pair_request_button.dart';

class PairRequestForm extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<String> onSubmit;

  const PairRequestForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<PairRequestForm> createState() => _PairRequestFormState();
}

class _PairRequestFormState extends State<PairRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _camoIdController = TextEditingController();

  @override
  void dispose() {
    _camoIdController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    widget.onSubmit(_camoIdController.text.trim());
  }

  String? _validateCamoId(String? value) {
    final camoId = value?.trim() ?? '';

    if (camoId.isEmpty) {
      return 'CAMO ID is required.';
    }

    final isValid = RegExp(r'^CM-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(camoId);

    if (!isValid) {
      return 'Enter a valid CAMO ID.';
    }

    return null;
  }

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
          const SizedBox(height: 16),
          SendPairRequestButton(
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}