import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

/// CAMO EA-002 local cryptographic validation.
///
/// Scope:
/// - Real X25519 key agreement.
/// - Real HKDF-SHA256 32-byte derivation.
/// - Real AES-256-GCM encryption and authenticated decryption.
/// - User A -> User B and User B -> User A round trips.
/// - Wrong-key, tamper and nonce-uniqueness security checks.
///
/// This is a TEST-ONLY integration harness.
/// It does not modify or activate the production Workspace DI binding.
void main() {
  const String userAId = 'camo-test-user-a-atish18k';
  const String userBId = 'camo-test-user-b-samaratish';
  const String pairingId = 'camo-local-test-pair-a-b-v1';

  final X25519 x25519 = X25519();
  final AesGcm aesGcm = AesGcm.with256bits();

  Future<SecretKey> deriveConversationKey({
    required SimpleKeyPair localKeyPair,
    required SimplePublicKey remotePublicKey,
  }) async {
    final SecretKey sharedSecret = await x25519.sharedSecretKey(
      keyPair: localKeyPair,
      remotePublicKey: remotePublicKey,
    );

    final List<int> sharedSecretBytes = await sharedSecret.extractBytes();

    final List<String> sortedUserIds = <String>[userAId, userBId]..sort();

    final List<int> hkdfInfo = utf8.encode(
      'CAMO|v1|${sortedUserIds[0]}|${sortedUserIds[1]}',
    );

    final Hkdf hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

    return hkdf.deriveKey(
      secretKey: SecretKey(sharedSecretBytes),
      nonce: utf8.encode(pairingId),
      info: hkdfInfo,
    );
  }

  Future<SecretBox> encryptText({
    required String plainText,
    required SecretKey key,
  }) {
    return aesGcm.encrypt(utf8.encode(plainText), secretKey: key);
  }

  Future<String> decryptText({
    required SecretBox secretBox,
    required SecretKey key,
  }) async {
    final List<int> clearBytes = await aesGcm.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(clearBytes);
  }

  group('CAMO billing-free real A-B cryptography', () {
    late SimpleKeyPair userAKeyPair;
    late SimplePublicKey userAPublicKey;

    late SimpleKeyPair userBKeyPair;
    late SimplePublicKey userBPublicKey;

    late SecretKey userAConversationKey;
    late SecretKey userBConversationKey;

    setUp(() async {
      userAKeyPair = await x25519.newKeyPair();
      userAPublicKey = await userAKeyPair.extractPublicKey();

      userBKeyPair = await x25519.newKeyPair();
      userBPublicKey = await userBKeyPair.extractPublicKey();

      userAConversationKey = await deriveConversationKey(
        localKeyPair: userAKeyPair,
        remotePublicKey: userBPublicKey,
      );

      userBConversationKey = await deriveConversationKey(
        localKeyPair: userBKeyPair,
        remotePublicKey: userAPublicKey,
      );
    });

    test(
      'User A and User B derive the same 256-bit conversation key',
      () async {
        final List<int> keyA = await userAConversationKey.extractBytes();

        final List<int> keyB = await userBConversationKey.extractBytes();

        expect(keyA, hasLength(32));
        expect(keyB, hasLength(32));
        expect(keyA, orderedEquals(keyB));
      },
    );

    test('User A encrypts and User B decrypts original plaintext', () async {
      const String originalPlainText =
          'CAMO A to B real encryption test: '
          'atish18k sends securely to samaratish.';

      final SecretBox encrypted = await encryptText(
        plainText: originalPlainText,
        key: userAConversationKey,
      );

      final String decoded = await decryptText(
        secretBox: encrypted,
        key: userBConversationKey,
      );

      expect(encrypted.cipherText, isNotEmpty);
      expect(encrypted.nonce, isNotEmpty);
      expect(encrypted.mac.bytes, isNotEmpty);
      expect(decoded, originalPlainText);
    });

    test('User B encrypts and User A decrypts original plaintext', () async {
      const String originalPlainText =
          'CAMO B to A real encryption test: '
          'samaratish replies securely to atish18k.';

      final SecretBox encrypted = await encryptText(
        plainText: originalPlainText,
        key: userBConversationKey,
      );

      final String decoded = await decryptText(
        secretBox: encrypted,
        key: userAConversationKey,
      );

      expect(encrypted.cipherText, isNotEmpty);
      expect(decoded, originalPlainText);
    });

    test(
      'same plaintext encrypted twice produces different nonce and output',
      () async {
        const String plainText = 'CAMO nonce uniqueness validation';

        final SecretBox first = await encryptText(
          plainText: plainText,
          key: userAConversationKey,
        );

        final SecretBox second = await encryptText(
          plainText: plainText,
          key: userAConversationKey,
        );

        expect(first.nonce, isNot(orderedEquals(second.nonce)));

        expect(first.cipherText, isNot(orderedEquals(second.cipherText)));
      },
    );

    test('wrong unrelated X25519 key cannot decrypt the payload', () async {
      const String plainText = 'CAMO wrong-key rejection test';

      final SecretBox encrypted = await encryptText(
        plainText: plainText,
        key: userAConversationKey,
      );

      final SimpleKeyPair attackerKeyPair = await x25519.newKeyPair();

      final SecretKey wrongConversationKey = await deriveConversationKey(
        localKeyPair: attackerKeyPair,
        remotePublicKey: userAPublicKey,
      );

      await expectLater(
        decryptText(secretBox: encrypted, key: wrongConversationKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('tampered ciphertext fails authenticated decryption', () async {
      const String plainText = 'CAMO authenticated tamper rejection test';

      final SecretBox encrypted = await encryptText(
        plainText: plainText,
        key: userAConversationKey,
      );

      final Uint8List modifiedCipherText = Uint8List.fromList(
        encrypted.cipherText,
      );

      modifiedCipherText[0] = modifiedCipherText[0] ^ 0x01;

      final SecretBox tampered = SecretBox(
        modifiedCipherText,
        nonce: encrypted.nonce,
        mac: encrypted.mac,
      );

      await expectLater(
        decryptText(secretBox: tampered, key: userBConversationKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('tampered authentication tag fails decryption', () async {
      const String plainText = 'CAMO authentication-tag validation test';

      final SecretBox encrypted = await encryptText(
        plainText: plainText,
        key: userAConversationKey,
      );

      final Uint8List modifiedMac = Uint8List.fromList(encrypted.mac.bytes);

      modifiedMac[0] = modifiedMac[0] ^ 0x01;

      final SecretBox tampered = SecretBox(
        encrypted.cipherText,
        nonce: encrypted.nonce,
        mac: Mac(modifiedMac),
      );

      await expectLater(
        decryptText(secretBox: tampered, key: userBConversationKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test(
      'different pairing salt derives a different conversation key',
      () async {
        final SecretKey sharedSecret = await x25519.sharedSecretKey(
          keyPair: userAKeyPair,
          remotePublicKey: userBPublicKey,
        );

        final List<int> sharedSecretBytes = await sharedSecret.extractBytes();

        final List<String> sortedUserIds = <String>[userAId, userBId]..sort();

        final Hkdf hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

        final SecretKey differentPairKey = await hkdf.deriveKey(
          secretKey: SecretKey(sharedSecretBytes),
          nonce: utf8.encode('different-pairing-id'),
          info: utf8.encode('CAMO|v1|${sortedUserIds[0]}|${sortedUserIds[1]}'),
        );

        final List<int> original = await userAConversationKey.extractBytes();

        final List<int> different = await differentPairKey.extractBytes();

        expect(original, isNot(orderedEquals(different)));
      },
    );
  });
}
