// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'camo_key_agreement.dart';

// ---------------------------------------------------------------------------
// X25519 Key Agreement
// ---------------------------------------------------------------------------

class CamoX25519KeyAgreement implements CamoKeyAgreement {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final X25519 _x25519 = X25519();

  // ---------------------------------------------------------------------------
  // Create Shared Secret
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> createSharedSecret({
    required Uint8List privateKey,
    required Uint8List remotePublicKey,
  }) async {
    final SimpleKeyPairData localKeyPair = SimpleKeyPairData(
      privateKey,
      publicKey: SimplePublicKey(
        <int>[],
        type: KeyPairType.x25519,
      ),
      type: KeyPairType.x25519,
    );

    final SimplePublicKey partnerPublicKey = SimplePublicKey(
      remotePublicKey,
      type: KeyPairType.x25519,
    );

    final SecretKey sharedSecretKey = await _x25519.sharedSecretKey(
      keyPair: localKeyPair,
      remotePublicKey: partnerPublicKey,
    );

    final List<int> sharedSecretBytes =
        await sharedSecretKey.extractBytes();

    return Uint8List.fromList(sharedSecretBytes);
  }
}