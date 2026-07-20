import 'dart:convert';
import 'dart:typed_data';

const int camoAuthorizationSchemaVersionV2 = 2;
const String camoAuthorizationCanonicalizationVersionV2 =
    'CAMO_AUTHORIZATION_V2';
const String camoAuthorizationSignatureAlgorithmV2 = 'EC_SIGN_P256_SHA256';
const String camoAuthorizationSignatureEncodingV2 = 'DER_BASE64';

final class CamoSignedAuthorizationContractV2 {
  CamoSignedAuthorizationContractV2({
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
    required this.payloadDigest,
    required this.keyReleaseId,
    required this.keyReference,
    required this.sessionId,
    required this.serverShareId,
    required this.serverShareVersion,
    required this.serverShareBase64,
    required this.serverShareExpiresAt,
    required this.issuedAt,
    required this.expiresAt,
    required this.reasonCode,
    required this.signatureAlgorithm,
    required this.signatureEncoding,
    required this.signingKeyId,
    required this.signature,
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
    'pairId',
    'messageId',
    'payloadDigest',
    'keyReleaseId',
    'keyReference',
    'sessionId',
    'serverShareId',
    'serverShareVersion',
    'serverShareBase64',
    'serverShareExpiresAt',
    'issuedAt',
    'expiresAt',
    'reasonCode',
    'signatureAlgorithm',
    'signatureEncoding',
    'signingKeyId',
    'signature',
  };

  final int schemaVersion;
  final String canonicalizationVersion;
  final String requestId;
  final bool authorized;
  final String authorizationId;
  final String operationId;
  final String challengeId;
  final String userId;
  final String deviceId;
  final String pairId;
  final String messageId;
  final String payloadDigest;
  final String keyReleaseId;
  final String keyReference;
  final String sessionId;
  final String serverShareId;
  final int serverShareVersion;
  final String serverShareBase64;
  final DateTime serverShareExpiresAt;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String reasonCode;
  final String signatureAlgorithm;
  final String signatureEncoding;
  final String signingKeyId;
  final String signature;

  Uint8List decodeServerShareBytes() {
    final Uint8List decoded;

    try {
      decoded = base64Decode(serverShareBase64);
    } on FormatException {
      throw const FormatException('ServerShare Base64 is invalid.');
    }

    if (decoded.length != 32) {
      throw const FormatException('ServerShare must contain exactly 32 bytes.');
    }

    return Uint8List.fromList(decoded);
  }

  factory CamoSignedAuthorizationContractV2.fromPayload(
    Map<String, Object?> payload,
  ) {
    _validateFieldSet(payload);

    final int schemaVersion = _requireInt(payload, 'schemaVersion');
    if (schemaVersion != camoAuthorizationSchemaVersionV2) {
      throw const FormatException('Unsupported authorization schema version.');
    }

    final String canonicalizationVersion = _requireString(
      payload,
      'canonicalizationVersion',
    );
    if (canonicalizationVersion != camoAuthorizationCanonicalizationVersionV2) {
      throw const FormatException(
        'Unsupported authorization canonicalization version.',
      );
    }

    final bool authorized = _requireBool(payload, 'authorized');
    if (!authorized) {
      throw const FormatException(
        'Denied authorization cannot be parsed as a signed V2 grant.',
      );
    }

    final String signatureAlgorithm = _requireString(
      payload,
      'signatureAlgorithm',
    );
    if (signatureAlgorithm != camoAuthorizationSignatureAlgorithmV2) {
      throw const FormatException(
        'Unsupported authorization signature algorithm.',
      );
    }

    final String signatureEncoding = _requireString(
      payload,
      'signatureEncoding',
    );
    if (signatureEncoding != camoAuthorizationSignatureEncodingV2) {
      throw const FormatException(
        'Unsupported authorization signature encoding.',
      );
    }

    final CamoSignedAuthorizationContractV2 contract =
        CamoSignedAuthorizationContractV2(
          schemaVersion: schemaVersion,
          canonicalizationVersion: canonicalizationVersion,
          requestId: _requireString(payload, 'requestId'),
          authorized: authorized,
          authorizationId: _requireString(payload, 'authorizationId'),
          operationId: _requireString(payload, 'operationId'),
          challengeId: _requireString(payload, 'challengeId'),
          userId: _requireString(payload, 'userId'),
          deviceId: _requireString(payload, 'deviceId'),
          pairId: _requireString(payload, 'pairId'),
          messageId: _requireString(payload, 'messageId'),
          payloadDigest: _requireString(payload, 'payloadDigest'),
          keyReleaseId: _requireString(payload, 'keyReleaseId'),
          keyReference: _requireString(payload, 'keyReference'),
          sessionId: _requireString(payload, 'sessionId'),
          serverShareId: _requireString(payload, 'serverShareId'),
          serverShareVersion: _requireInt(payload, 'serverShareVersion'),
          serverShareBase64: _requireString(payload, 'serverShareBase64'),
          serverShareExpiresAt: _requireUtcDateTime(
            payload,
            'serverShareExpiresAt',
          ),
          issuedAt: _requireUtcDateTime(payload, 'issuedAt'),
          expiresAt: _requireUtcDateTime(payload, 'expiresAt'),
          reasonCode: _requireString(payload, 'reasonCode'),
          signatureAlgorithm: signatureAlgorithm,
          signatureEncoding: signatureEncoding,
          signingKeyId: _requireString(payload, 'signingKeyId'),
          signature: _requireString(payload, 'signature'),
        );

    if (contract.serverShareVersion != 1) {
      throw const FormatException('Unsupported ServerShare version.');
    }

    if (!contract.serverShareExpiresAt.isAfter(contract.issuedAt) ||
        contract.serverShareExpiresAt.isAfter(contract.expiresAt)) {
      throw const FormatException('ServerShare expiry is invalid.');
    }

    contract.decodeServerShareBytes();
    return contract;
  }

  static void _validateFieldSet(Map<String, Object?> payload) {
    for (final String field in _requiredFields) {
      if (!payload.containsKey(field)) {
        throw FormatException(
          'Authorization response field is missing: $field.',
        );
      }
    }

    for (final String field in payload.keys) {
      if (!_requiredFields.contains(field)) {
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

    if (value.contains('\n') || value.contains('\r')) {
      throw FormatException(
        'Authorization response field contains line break: $field.',
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

  static DateTime _requireUtcDateTime(
    Map<String, Object?> payload,
    String field,
  ) {
    final String value = _requireString(payload, field);
    final DateTime? parsed = DateTime.tryParse(value);

    if (parsed == null || !value.endsWith('Z')) {
      throw FormatException('Authorization timestamp is invalid: $field.');
    }

    return parsed.toUtc();
  }
}
