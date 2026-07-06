// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class IdentityQrDialog extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const IdentityQrDialog({
    super.key,
    required this.camoId,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String camoId;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('CAMO QR'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 220,
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code,
              size: 180,
            ),
          ),

          const SizedBox(height: 16),

          SelectableText(
            camoId,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}