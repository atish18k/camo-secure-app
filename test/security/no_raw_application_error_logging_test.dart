import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application source contains no raw logging calls', () {
    final Directory sourceDirectory = Directory('lib');

    expect(
      sourceDirectory.existsSync(),
      isTrue,
      reason: 'Application source must remain auditable.',
    );

    final List<File> dartFiles = sourceDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList(growable: false);

    final List<String> prohibitedMarkers = <String>[
      'debugPrint(',
      'debugPrintStack(',
      'print(',
    ];

    final List<String> violations = <String>[];

    for (final File file in dartFiles) {
      final String source = file.readAsStringSync();

      for (final String marker in prohibitedMarkers) {
        if (source.contains(marker)) {
          violations.add('${file.path}: $marker');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Raw client logs can expose authentication, pairing, '
          'authorization, or cryptographic data.',
    );
  });
}
