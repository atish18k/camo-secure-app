// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../server_share/camo_server_share.dart';
import 'camo_final_key_derivation.dart';

// ---------------------------------------------------------------------------
// CAMO HKDF Final Key Derivation
// ---------------------------------------------------------------------------

final class CamoHkdfFinalKeyDerivation implements CamoFinalKeyDerivation {
  const CamoHkdfFinalKeyDerivation();

  static const int keyLength = 32;

  @override
  Future<Uint8List> deriveFinalKey({
    required Uint8List deviceSharedSecret,
    required CamoServerShare serverShare,
    required Uint8List salt,
    required List<int> info,
  }) async {
    if (deviceSharedSecret.isEmpty) {
      throw StateError('Device shared secret is required.');
    }

    if (serverShare.bytes.length != 32) {
      throw StateError('Validated 32-byte server share is required.');
    }

    if (salt.isEmpty) {
      throw StateError('Final key salt is required.');
    }

    if (info.isEmpty) {
      throw StateError('Final key context information is required.');
    }

    final Uint8List inputKeyMaterial =
        Uint8List(deviceSharedSecret.length + serverShare.bytes.length)
          ..setRange(0, deviceSharedSecret.length, deviceSharedSecret)
          ..setRange(
            deviceSharedSecret.length,
            deviceSharedSecret.length + serverShare.bytes.length,
            serverShare.bytes,
          );

    final Hkdf hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: keyLength);

    final SecretKey derivedSecretKey = await hkdf.deriveKey(
      secretKey: SecretKey(inputKeyMaterial),
      nonce: salt,
      info: info,
    );

    final List<int> keyBytes = await derivedSecretKey.extractBytes();

    if (keyBytes.length != keyLength) {
      throw StateError('Final CAMO key must contain exactly 32 bytes.');
    }

    return Uint8List.fromList(keyBytes);
  }
}
