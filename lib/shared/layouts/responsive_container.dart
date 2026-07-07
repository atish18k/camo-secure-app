// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class ResponsiveContainer extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final Widget child;
  final double maxWidth;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }
}