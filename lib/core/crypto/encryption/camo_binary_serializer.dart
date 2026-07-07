// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_crypto_payload.dart';

// ---------------------------------------------------------------------------
// Binary Serializer
// ---------------------------------------------------------------------------

class CamoBinarySerializer {
  // ---------------------------------------------------------------------------
  // Serialize
  // ---------------------------------------------------------------------------

  Uint8List serialize(
    CamoCryptoPayload payload,
  ) {
    final Map<String, dynamic> map = {
      'v': payload.version,
      'alg': payload.algorithm,
      'n': payload.nonce,
      'ct': payload.cipherText,
      'tag': payload.authenticationTag,
      'ts': payload.createdAt.toUtc().millisecondsSinceEpoch,
      'camo': payload.camouflageEnabled,
      'sub': payload.subject,
    };

    return Uint8List.fromList(
      utf8.encode(
        jsonEncode(map),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Deserialize
  // ---------------------------------------------------------------------------

  CamoCryptoPayload deserialize(
    Uint8List bytes,
  ) {
    final Map<String, dynamic> map = jsonDecode(
      utf8.decode(bytes),
    ) as Map<String, dynamic>;

    return CamoCryptoPayload(
      version: map['v'] as int,
      algorithm: map['alg'] as String,
      nonce: map['n'] as String,
      cipherText: map['ct'] as String,
      authenticationTag: map['tag'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['ts'] as int,
        isUtc: true,
      ),
      camouflageEnabled: map['camo'] as bool? ?? false,
      subject: map['sub'] as String?,
    );
  }
}