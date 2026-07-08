// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'camo_key_derivation.dart';

// ---------------------------------------------------------------------------
// HKDF Key Derivation
// ---------------------------------------------------------------------------

class CamoHkdfKeyDerivation implements CamoKeyDerivation {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const int keyLength = 32;

  // ---------------------------------------------------------------------------
  // Derive Key
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> deriveKey({
    required String localUserId,
    required String remoteUserId,
    required Uint8List sharedSecret,
    required Uint8List salt,
  }) async {
    final List<String> sortedUserIds = <String>[
      localUserId,
      remoteUserId,
    ]..sort();

    final List<int> info = utf8.encode(
      'CAMO|v1|${sortedUserIds[0]}|${sortedUserIds[1]}',
    );

    final Hkdf hkdf = Hkdf(
      hmac: Hmac.sha256(),
      outputLength: keyLength,
    );

    final SecretKey derivedSecretKey = await hkdf.deriveKey(
      secretKey: SecretKey(sharedSecret),
      nonce: salt,
      info: info,
    );

    final List<int> keyBytes = await derivedSecretKey.extractBytes();

    return Uint8List.fromList(keyBytes);
  }
}