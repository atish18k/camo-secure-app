import 'dart:convert';

final class CamoStandardCryptoContextV2 {
  const CamoStandardCryptoContextV2._();

  static List<int> build({
    required String operationId,
    required String messageId,
    required String pairingId,
    required String authorizationId,
    required String challengeId,
  }) {
    final List<String> values = <String>[
      operationId.trim(),
      messageId.trim(),
      pairingId.trim(),
      authorizationId.trim(),
      challengeId.trim(),
    ];

    if (values.any((String value) => value.isEmpty)) {
      throw StateError('Canonical V2 Standard CAMO context is incomplete.');
    }

    return utf8.encode(
      'CAMO|standard-message|v2'
      '|${values[0]}'
      '|${values[1]}'
      '|${values[2]}'
      '|${values[3]}'
      '|${values[4]}',
    );
  }
}
