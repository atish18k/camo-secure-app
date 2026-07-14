import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QR scanner never logs scanned payloads', () {
    final File sourceFile = File(
      'lib/features/pairing/presentation/screens/'
      'qr_scanner_screen.dart',
    );

    expect(
      sourceFile.existsSync(),
      isTrue,
      reason: 'QR scanner source must remain auditable.',
    );

    final String source = sourceFile.readAsStringSync();

    expect(
      source,
      isNot(contains('SCANNED_QR_VALUE:')),
      reason: 'QR payload labels must never be written to application logs.',
    );

    expect(
      RegExp(r'debugPrint\s*\(\s*value\s*\)').hasMatch(source),
      isFalse,
      reason: 'Raw scanned QR values must never be logged.',
    );
  });
}