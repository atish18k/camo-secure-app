import 'dart:convert';

const int camoAuthorizationSchemaVersionV1 = 1;

const String camoAuthorizationCanonicalizationVersionV1 =
    'CAMO_AUTHORIZATION_V1';

const String camoAuthorizationSignatureAlgorithmV1 = 'EC_SIGN_P256_SHA256';

const String camoAuthorizationSignatureEncodingV1 = 'DER_BASE64';

final class CamoSignedAuthorizationContractV1 {
  CamoSignedAuthorizationContractV1._({
    required this.schemaVersion,
    required this.canonicalizationVersion,
    required this.requestId,
    required this.authorized,
    required this.authorizationId,
    required this.operationId,
    required this.challengeId,
    required this.userId,
    required this.deviceId,
    required this.pairId,
    required this.messageId,
    required this.keyReleaseId,
    required this.keyReference,
    required this.sessionId,
    required this.issuedAt,
    required this.expiresAt,
    required this.reasonCode,
    required this.signature,
    required this.signingKeyId,
    required this.signatureAlgorithm,
    required this.signatureEncoding,
  });

  static const Set<String> _requiredFields = <String>{
    'schemaVersion',
    'canonicalizationVersion',
    'requestId',
    'authorized',
    'authorizationId',
    'operationId',
    'challengeId',
    'userId',
    'deviceId',
    'keyReleaseId',
    'keyReference',
    'sessionId',
    'issuedAt',
    'expiresAt',
    'reasonCode',
    'signature',
    'signingKeyId',
    'signatureAlgorithm',
    'signatureEncoding',
  };

  static const Set<String> _optionalFields = <String>{'pairId', 'messageId'};

  final int schemaVersion;
  final String canonicalizationVersion;
  final String requestId;
  final bool authorized;
  final String authorizationId;
  final String operationId;
  final String challengeId;
  final String userId;
  final String deviceId;
  final String? pairId;
  final String? messageId;
  final String keyReleaseId;
  final String keyReference;
  final String sessionId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String reasonCode;
  final String signature;
  final String signingKeyId;
  final String signatureAlgorithm;
  final String signatureEncoding;

  bool get isWithinValidityWindow {
    return expiresAt.isAfter(issuedAt);
  }

  List<int> decodeDerSignature() {
    try {
      final List<int> decoded = base64Decode(signature);

      if (decoded.isEmpty) {
        throw const FormatException('Authorization signature bytes are empty.');
      }

      return List<int>.unmodifiable(decoded);
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException(
        'Authorization signature is not valid Base64.',
      );
    }
  }

  static CamoSignedAuthorizationContractV1 parse(Map<Object?, Object?> input) {
    final Map<String, Object?> payload = _normalizeMap(input);

    _requireExactFieldBoundary(payload);

    final int schemaVersion = _requireInt(payload, 'schemaVersion');

    if (schemaVersion != camoAuthorizationSchemaVersionV1) {
      throw const FormatException('Unsupported authorization schema version.');
    }

    final String canonicalizationVersion = _requireString(
      payload,
      'canonicalizationVersion',
    );

    if (canonicalizationVersion != camoAuthorizationCanonicalizationVersionV1) {
      throw const FormatException(
        'Unsupported authorization canonicalization version.',
      );
    }

    final bool authorized = _requireBool(payload, 'authorized');

    if (!authorized) {
      throw const FormatException(
        'Denied authorization cannot be parsed as a signed grant.',
      );
    }

    final String signatureAlgorithm = _requireString(
      payload,
      'signatureAlgorithm',
    );

    if (signatureAlgorithm != camoAuthorizationSignatureAlgorithmV1) {
      throw const FormatException(
        'Unsupported authorization signature algorithm.',
      );
    }

    final String signatureEncoding = _requireString(
      payload,
      'signatureEncoding',
    );

    if (signatureEncoding != camoAuthorizationSignatureEncodingV1) {
      throw const FormatException(
        'Unsupported authorization signature encoding.',
      );
    }

    final DateTime issuedAt = _requireTimestamp(payload, 'issuedAt');
    final DateTime expiresAt = _requireTimestamp(payload, 'expiresAt');

    if (!expiresAt.isAfter(issuedAt)) {
      throw const FormatException('Authorization validity window is invalid.');
    }

    final CamoSignedAuthorizationContractV1 contract =
        CamoSignedAuthorizationContractV1._(
          schemaVersion: schemaVersion,
          canonicalizationVersion: canonicalizationVersion,
          requestId: _requireString(payload, 'requestId'),
          authorized: authorized,
          authorizationId: _requireString(payload, 'authorizationId'),
          operationId: _requireString(payload, 'operationId'),
          challengeId: _requireString(payload, 'challengeId'),
          userId: _requireString(payload, 'userId'),
          deviceId: _requireString(payload, 'deviceId'),
          pairId: _optionalString(payload, 'pairId'),
          messageId: _optionalString(payload, 'messageId'),
          keyReleaseId: _requireString(payload, 'keyReleaseId'),
          keyReference: _requireString(payload, 'keyReference'),
          sessionId: _requireString(payload, 'sessionId'),
          issuedAt: issuedAt,
          expiresAt: expiresAt,
          reasonCode: _requireString(payload, 'reasonCode'),
          signature: _requireString(payload, 'signature'),
          signingKeyId: _requireString(payload, 'signingKeyId'),
          signatureAlgorithm: signatureAlgorithm,
          signatureEncoding: signatureEncoding,
        );

    contract.decodeDerSignature();

    return contract;
  }

  static Map<String, Object?> _normalizeMap(Map<Object?, Object?> input) {
    final Map<String, Object?> result = <String, Object?>{};

    for (final MapEntry<Object?, Object?> entry in input.entries) {
      final Object? key = entry.key;

      if (key is! String || key.trim().isEmpty) {
        throw const FormatException(
          'Authorization response contains an invalid field name.',
        );
      }

      if (result.containsKey(key)) {
        throw FormatException(
          'Authorization response contains a duplicate field: $key.',
        );
      }

      result[key] = entry.value;
    }

    return Map<String, Object?>.unmodifiable(result);
  }

  static void _requireExactFieldBoundary(Map<String, Object?> payload) {
    for (final String field in _requiredFields) {
      if (!payload.containsKey(field)) {
        throw FormatException(
          'Authorization response is missing required field: $field.',
        );
      }
    }

    final Set<String> allowedFields = <String>{
      ..._requiredFields,
      ..._optionalFields,
    };

    for (final String field in payload.keys) {
      if (!allowedFields.contains(field)) {
        throw FormatException(
          'Authorization response contains unknown field: $field.',
        );
      }
    }
  }

  static String _requireString(Map<String, Object?> payload, String field) {
    final Object? value = payload[field];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Authorization response field is invalid: $field.');
    }

    return value.trim();
  }

  static String? _optionalString(Map<String, Object?> payload, String field) {
    final Object? value = payload[field];

    if (value == null) {
      return null;
    }

    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'Authorization response optional field is invalid: $field.',
      );
    }

    return value.trim();
  }

  static int _requireInt(Map<String, Object?> payload, String field) {
    final Object? value = payload[field];

    if (value is! int) {
      throw FormatException('Authorization response field is invalid: $field.');
    }

    return value;
  }

  static bool _requireBool(Map<String, Object?> payload, String field) {
    final Object? value = payload[field];

    if (value is! bool) {
      throw FormatException('Authorization response field is invalid: $field.');
    }

    return value;
  }

  static DateTime _requireTimestamp(
    Map<String, Object?> payload,
    String field,
  ) {
    final String value = _requireString(payload, field);
    final DateTime? timestamp = DateTime.tryParse(value);

    if (timestamp == null || !value.endsWith('Z')) {
      throw FormatException(
        'Authorization response timestamp is invalid: $field.',
      );
    }

    return timestamp.toUtc();
  }
}
