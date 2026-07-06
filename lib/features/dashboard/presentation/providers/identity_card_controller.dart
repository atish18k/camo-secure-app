// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class IdentityCardController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  IdentityCardController({
    required this.camoId,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String camoId;

  bool _isVisible = false;
  bool _isCopied = false;
  Timer? _copyResetTimer;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isVisible => _isVisible;

  bool get isHidden => !_isVisible;

  bool get isCopied => _isCopied;

  bool get hasValidCamoId => _isValidCamoId(camoId);

  String get displayCamoId {
    if (camoId.trim().isEmpty) {
      return 'CAMO-••••-••••';
    }

    if (_isVisible) {
      return camoId;
    }

    return _maskCamoId(camoId);
  }

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  void reveal() {
    if (_isVisible) {
      return;
    }

    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    if (!_isVisible) {
      return;
    }

    _isVisible = false;
    notifyListeners();
  }

  void toggleVisibility() {
    _isVisible ? hide() : reveal();
  }

  Future<bool> copyCamoId() async {
    if (!hasValidCamoId) {
      return false;
    }

    try {
      await Clipboard.setData(
        ClipboardData(text: camoId),
      );

      _markAsCopied();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  void _markAsCopied() {
    _copyResetTimer?.cancel();

    _isCopied = true;
    notifyListeners();

    _copyResetTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        _isCopied = false;
        notifyListeners();
      },
    );
  }

  bool _isValidCamoId(String value) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return false;
    }

    switch (trimmedValue) {
      case 'CAMO-XXXX-XXXX':
      case 'Not Signed In':
      case 'Profile Not Found':
        return false;

      default:
        return true;
    }
  }

  String _maskCamoId(String value) {
    final List<String> parts = value.split('-');

    if (parts.length >= 3) {
      return '${parts.first}-••••-••••';
    }

    return '••••••••';
  }
}