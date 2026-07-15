import '../models/camo_signed_authorization_contract_v1.dart';

final class CamoSignedAuthorizationContractV1Canonicalizer {
  const CamoSignedAuthorizationContractV1Canonicalizer();

  String canonicalize(CamoSignedAuthorizationContractV1 contract) {
    return <String>[
      'schemaVersion=${contract.schemaVersion}',
      'canonicalizationVersion=${_requiredValue(contract.canonicalizationVersion)}',
      'requestId=${_requiredValue(contract.requestId)}',
      'authorized=${contract.authorized ? 'true' : 'false'}',
      'authorizationId=${_requiredValue(contract.authorizationId)}',
      'operationId=${_requiredValue(contract.operationId)}',
      'challengeId=${_requiredValue(contract.challengeId)}',
      'userId=${_requiredValue(contract.userId)}',
      'deviceId=${_requiredValue(contract.deviceId)}',
      'pairId=${_optionalValue(contract.pairId)}',
      'messageId=${_optionalValue(contract.messageId)}',
      'keyReleaseId=${_requiredValue(contract.keyReleaseId)}',
      'keyReference=${_requiredValue(contract.keyReference)}',
      'sessionId=${_requiredValue(contract.sessionId)}',
      'issuedAt=${contract.issuedAt.toUtc().toIso8601String()}',
      'expiresAt=${contract.expiresAt.toUtc().toIso8601String()}',
      'reasonCode=${_requiredValue(contract.reasonCode)}',
    ].join('\n');
  }

  String _requiredValue(String value) {
    final String normalized = value.trim();

    if (normalized.isEmpty ||
        normalized.contains('\n') ||
        normalized.contains('\r')) {
      throw const FormatException('Canonical authorization field is invalid.');
    }

    return normalized;
  }

  String _optionalValue(String? value) {
    if (value == null) {
      return '';
    }

    return _requiredValue(value);
  }
}
