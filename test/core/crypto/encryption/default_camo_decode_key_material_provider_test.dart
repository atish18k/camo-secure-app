import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider requires authenticated accepted-pair context', () {
    final String source = File(
      'lib/core/crypto/encryption/'
      'default_camo_decode_key_material_provider.dart',
    ).readAsStringSync();

    expect(source, contains('_authRepository.isSignedIn'));
    expect(source, contains('PairingStatus.accepted'));
    expect(source, contains('Current user is not part of this pairing.'));
  });

  test(
    'provider derives raw X25519 shared secret from device and remote keys',
    () {
      final String source = File(
        'lib/core/crypto/encryption/'
        'default_camo_decode_key_material_provider.dart',
      ).readAsStringSync();

      expect(source, contains('_deviceKeyManager.loadKeyPair()'));
      expect(source, contains('.getPublicKey(remoteUserId: remoteUserId)'));
      expect(source, contains('_keyAgreement.createSharedSecret('));
      expect(source, contains('privateKey: keyPair.privateKey'));
      expect(source, contains('remotePublicKey: remotePublicKey'));
    },
  );

  test('provider binds salt to the exact accepted pairing id', () {
    final String source = File(
      'lib/core/crypto/encryption/'
      'default_camo_decode_key_material_provider.dart',
    ).readAsStringSync();

    expect(source, contains('utf8.encode(pairing.id.trim())'));
    expect(source, isNot(contains('utf8.encode(remoteUserId)')));
  });

  test('material value defensively copies secret and salt bytes', () {
    final String source = File(
      'lib/core/crypto/encryption/camo_decode_key_material.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('deviceSharedSecret = Uint8List.fromList(deviceSharedSecret)'),
    );
    expect(source, contains('salt = Uint8List.fromList(salt)'));
  });

  test('provider does not invoke legacy decode or conversation-key cache', () {
    final String source = File(
      'lib/core/crypto/encryption/'
      'default_camo_decode_key_material_provider.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('decodeForPair')));
    expect(source, isNot(contains('keyCache')));
    expect(source, isNot(contains('deriveKey(')));
  });
}
