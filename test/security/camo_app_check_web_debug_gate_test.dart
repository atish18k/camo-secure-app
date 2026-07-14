import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web App Check debug gate is loopback and port restricted', () {
    final File webIndex = File('web/index.html');

    expect(webIndex.existsSync(), isTrue);

    final String source = webIndex.readAsStringSync();

    expect(source, contains("'52102'"));
    expect(source, contains("'52103'"));
    expect(source, contains("'52104'"));
    expect(source, contains("'localhost'"));
    expect(source, contains("'127.0.0.1'"));
    expect(source, contains('FIREBASE_APPCHECK_DEBUG_TOKEN = true'));

    final RegExp embeddedUuid = RegExp(
      r'FIREBASE_APPCHECK_DEBUG_TOKEN\s*=\s*'
      r'["'
      ']'
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{12}'
      r'["'
      ']',
    );

    expect(
      embeddedUuid.hasMatch(source),
      isFalse,
      reason: 'Registered debug tokens must never be committed.',
    );
  });
}
