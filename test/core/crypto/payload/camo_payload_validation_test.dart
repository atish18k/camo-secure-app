import 'dart:typed_data';

import 'package:camo/features/payload/data/parsers/camo_compact_payload_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Camo compact payload validation', () {
    final parser = CamoCompactPayloadParser();

    test('throws FormatException for empty payload', () {
      expect(
        () => parser.parse(Uint8List(0)),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for payload shorter than minimum length', () {
      expect(
        () => parser.parse(Uint8List.fromList(<int>[1, 2, 3])),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for invalid metadata length', () {
      final bytes = Uint8List.fromList(<int>[
        // Nonce: 12 bytes
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,

        // Header: version, flags, metadata length = 20
        1, 0, 0, 20,

        // Not enough metadata bytes
        1, 2, 3,
      ]);

      expect(
        () => parser.parse(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when ciphertext is missing', () {
      final bytes = Uint8List.fromList(<int>[
        // Nonce: 12 bytes
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,

        // Header: version, flags, metadata length = 0
        1, 0, 0, 0,
      ]);

      expect(
        () => parser.parse(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses valid minimal packet', () {
      final bytes = Uint8List.fromList(<int>[
        // Nonce: 12 bytes
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,

        // Header: version, flags, metadata length = 0
        1, 0, 0, 0,

        // Ciphertext
        99,
      ]);

      final packet = parser.parse(bytes);

      expect(packet.version, 1);
      expect(packet.flags, 0);
      expect(packet.metadata, isNull);
      expect(packet.nonce.length, 12);
      expect(packet.cipherText, Uint8List.fromList(<int>[99]));
    });
  });
}