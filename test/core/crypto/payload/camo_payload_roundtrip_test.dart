import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:camo/features/payload/data/parsers/camo_compact_payload_parser.dart';
import 'package:camo/features/payload/data/serializers/camo_compact_payload_serializer.dart';
import 'package:camo/features/payload/domain/entities/camo_payload_packet.dart';

void main() {
  group('Camo compact payload round-trip', () {
    test('serializes and parses packet without metadata', () {
      final serializer = CamoCompactPayloadSerializer();
      final parser = CamoCompactPayloadParser();

      final packet = CamoPayloadPacket(
        version: 1,
        flags: 0,
        nonce: Uint8List.fromList(List<int>.generate(12, (index) => index)),
        cipherText: Uint8List.fromList(
          List<int>.generate(32, (index) => index + 20),
        ),
      );

      final encoded = serializer.serialize(packet);
      final decoded = parser.parse(encoded);

      expect(decoded.version, packet.version);
      expect(decoded.flags, packet.flags);
      expect(decoded.metadata, isNull);
      expect(decoded.nonce, packet.nonce);
      expect(decoded.cipherText, packet.cipherText);
    });

    test('serializes and parses packet with metadata', () {
      final serializer = CamoCompactPayloadSerializer();
      final parser = CamoCompactPayloadParser();

      final metadata = Uint8List.fromList(<int>[1, 2, 3, 4]);

      final packet = CamoPayloadPacket(
        version: 1,
        flags: 1,
        metadata: metadata,
        nonce: Uint8List.fromList(List<int>.generate(12, (index) => index)),
        cipherText: Uint8List.fromList(
          List<int>.generate(32, (index) => index + 50),
        ),
      );

      final encoded = serializer.serialize(packet);
      final decoded = parser.parse(encoded);

      expect(decoded.version, packet.version);
      expect(decoded.flags, packet.flags);
      expect(decoded.metadata, metadata);
      expect(decoded.nonce, packet.nonce);
      expect(decoded.cipherText, packet.cipherText);
    });
  });
}