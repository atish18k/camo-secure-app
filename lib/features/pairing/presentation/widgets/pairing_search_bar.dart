// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class PairingSearchBar extends StatelessWidget {
  const PairingSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Search',
        hintText: 'Name or CAMO ID',
        prefixIcon: Icon(Icons.search_rounded),
        border: OutlineInputBorder(),
      ),
    );
  }
}
