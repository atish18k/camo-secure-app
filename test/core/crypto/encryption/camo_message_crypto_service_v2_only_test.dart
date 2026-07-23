import 'dart:typed_data';

import 'package:camo/core/crypto/encryption/camo_aes_gcm_engine.dart';
import 'package:camo/core/crypto/encryption/camo_message_crypto_service.dart';
import 'package:camo/core/crypto/encryption/camo_secure_nonce_generator.dart';
import 'package:camo/core/crypto/encryption/camo_secure_random.dart';
import 'package:camo/features/payload/data/parsers/camo_compact_payload_parser.dart';
import 'package:camo/features/payload/data/serializers/camo_compact_payload_serializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final CamoMessageCryptoService service = CamoMessageCryptoService(
    nonceGenerator: CamoSecureNonceGenerator(CamoSecureRandom()),
    cryptoEngine: CamoAesGcmEngine(),
    payloadSerializer: CamoCompactPayloadSerializer(),
    payloadParser: CamoCompactPayloadParser(),
  );

  test('strict V2 decoder rejects malformed non-V2 input', () async {
    await expectLater(
      service.decodeV2Only(encodedText: 'not-v2!', key: Uint8List(32)),
      throwsFormatException,
    );
  });

  test('strict V2 decoder rejects empty payload', () async {
    await expectLater(
      service.decodeV2Only(encodedText: '   ', key: Uint8List(32)),
      throwsStateError,
    );
  });

  test(
    'strict V2 decoder accepts packet produced by current encoder',
    () async {
      final Uint8List key = Uint8List.fromList(
        List<int>.generate(32, (int index) => index),
      );

      final String encoded = await service.encode(
        plainText: 'strict-v2-message',
        key: key,
        camouflageEnabled: false,
      );

      final String decoded = await service.decodeV2Only(
        encodedText: encoded,
        key: key,
      );

      expect(decoded, 'strict-v2-message');
    },
  );
}
