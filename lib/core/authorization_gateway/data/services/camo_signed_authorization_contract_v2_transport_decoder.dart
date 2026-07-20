import '../../domain/entities/camo_authorization_signature_verification_decision.dart';
import '../models/camo_signed_authorization_contract_v2.dart';

typedef CamoSignedAuthorizationContractV2Verification =
    Future<CamoAuthorizationSignatureVerificationDecision> Function(
      CamoSignedAuthorizationContractV2 contract,
    );

final class CamoSignedAuthorizationContractV2TransportDecoder {
  const CamoSignedAuthorizationContractV2TransportDecoder({
    required this.verifyContract,
  });

  final CamoSignedAuthorizationContractV2Verification verifyContract;

  Future<CamoSignedAuthorizationContractV2> decodeAndVerify({
    required Map<Object?, Object?> payload,
    required String expectedRequestId,
  }) async {
    try {
      if (expectedRequestId.trim().isEmpty) {
        throw StateError('Expected request identifier is unavailable.');
      }

      final Map<String, Object?> normalized = _normalizePayload(payload);

      final CamoSignedAuthorizationContractV2 contract =
          CamoSignedAuthorizationContractV2.fromPayload(normalized);

      if (contract.requestId != expectedRequestId.trim()) {
        throw StateError('Authorization V2 request binding failed.');
      }

      final CamoAuthorizationSignatureVerificationDecision decision =
          await verifyContract(contract);

      if (!decision.permitsResponseUse) {
        throw StateError('Authorization V2 signature verification was denied.');
      }

      return contract;
    } on Object {
      throw StateError(
        'Signed authorization V2 response verification failed closed.',
      );
    }
  }

  Map<String, Object?> _normalizePayload(Map<Object?, Object?> payload) {
    final Map<String, Object?> normalized = <String, Object?>{};

    for (final MapEntry<Object?, Object?> entry in payload.entries) {
      if (entry.key is! String || (entry.key! as String).trim().isEmpty) {
        throw const FormatException(
          'Authorization V2 response contains invalid field name.',
        );
      }

      final String key = (entry.key! as String).trim();

      if (normalized.containsKey(key)) {
        throw FormatException(
          'Authorization V2 response contains duplicate field: $key.',
        );
      }

      normalized[key] = entry.value;
    }

    return Map<String, Object?>.unmodifiable(normalized);
  }
}
