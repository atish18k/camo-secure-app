import '../models/camo_signed_authorization_contract_v2.dart';

final class CamoSignedAuthorizationContractV2Canonicalizer {
  const CamoSignedAuthorizationContractV2Canonicalizer();

  String canonicalize(CamoSignedAuthorizationContractV2 contract) {
    if (!contract.authorized) {
      throw const FormatException(
        'V2 canonicalization requires an authorized grant.',
      );
    }

    return <String>[
      'schemaVersion=${contract.schemaVersion}',
      'canonicalizationVersion=${_required(contract.canonicalizationVersion)}',
      'requestId=${_required(contract.requestId)}',
      'authorized=true',
      'authorizationId=${_required(contract.authorizationId)}',
      'operationId=${_required(contract.operationId)}',
      'challengeId=${_required(contract.challengeId)}',
      'userId=${_required(contract.userId)}',
      'deviceId=${_required(contract.deviceId)}',
      'pairId=${_required(contract.pairId)}',
      'messageId=${_required(contract.messageId)}',
      'payloadDigest=${_required(contract.payloadDigest)}',
      'keyReleaseId=${_required(contract.keyReleaseId)}',
      'keyReference=${_required(contract.keyReference)}',
      'sessionId=${_required(contract.sessionId)}',
      'serverShareId=${_required(contract.serverShareId)}',
      'serverShareVersion=${contract.serverShareVersion}',
      'serverShareBase64=${_required(contract.serverShareBase64)}',
      'serverShareExpiresAt=${contract.serverShareExpiresAt.toIso8601String()}',
      'issuedAt=${contract.issuedAt.toIso8601String()}',
      'expiresAt=${contract.expiresAt.toIso8601String()}',
      'reasonCode=${_required(contract.reasonCode)}',
    ].join('\n');
  }

  String _required(String value) {
    final String normalized = value.trim();

    if (normalized.isEmpty ||
        normalized.contains('\n') ||
        normalized.contains('\r')) {
      throw const FormatException('Canonical field is invalid.');
    }

    return normalized;
  }
}
