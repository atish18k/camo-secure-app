// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_crypto_payload.dart';

// ---------------------------------------------------------------------------
// Legacy Binary Serializer
// ---------------------------------------------------------------------------
//
// NOTE:
// This serializer is legacy-compatible only.
//
// Despite the historical name, this is NOT the new compact binary packet
// serializer. It converts the legacy CM1 payload model into JSON bytes.
//
// New compact binary payloads use:
// features/payload/data/serializers/camo_compact_payload_serializer.dart
//
// Keep this file until legacy decode migration is fully removed in a future
// stable version.
// ---------------------------------------------------------------------------

class CamoBinarySerializer {
  // ---------------------------------------------------------------------------
  // Serialize Legacy Payload
  // ---------------------------------------------------------------------------

  Uint8List serialize(
    CamoCryptoPayload payload,
  ) {
    final Map<String, dynamic> map = <String, dynamic>{
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
  // Deserialize Legacy Payload
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