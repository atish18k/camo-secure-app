import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encode and decode use the same canonical V2 context builder', () {
    final String encryptor = File(
      'lib/core/crypto/encryption/camo_standard_camo_encryptor.dart',
    ).readAsStringSync();
    final String decryptor = File(
      'lib/core/crypto/encryption/camo_standard_uncamo_decryptor.dart',
    ).readAsStringSync();

    expect(encryptor, contains('CamoStandardCryptoContextV2.build('));
    expect(decryptor, contains('CamoStandardCryptoContextV2.build('));
  });

  test('verified V2 runtime DI uses strict decoder only', () {
    final String di = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(di, contains('CamoMessageCryptoService>().decodeV2Only('));
  });

  test('message crypto service exposes only the compact decode path', () {
    final String source = File(
      'lib/core/crypto/encryption/camo_message_crypto_service.dart',
    ).readAsStringSync();

    expect(source, contains('Future<String> decodeV2Only({'));
    expect(source, contains('Only strict CAMO V2 payloads are accepted.'));
    expect(source, contains('return _decodeCompact('));
  });
}
