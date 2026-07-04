import 'package:flutter/services.dart';

class CamoIdInputFormatter extends TextInputFormatter {
  static const String _prefix = 'CM-';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only letters and digits.
    var value = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    // Remove optional CM prefix if user typed it.
    if (value.startsWith('CM')) {
      value = value.substring(2);
    }

    // Limit to 8 random characters.
    if (value.length > 8) {
      value = value.substring(0, 8);
    }

    final buffer = StringBuffer(_prefix);

    for (var i = 0; i < value.length; i++) {
      if (i == 4) {
        buffer.write('-');
      }
      buffer.write(value[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}