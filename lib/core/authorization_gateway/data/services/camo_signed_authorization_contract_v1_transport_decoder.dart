import '../../domain/entities/camo_authorization_signature_verification_decision.dart';
import '../models/camo_signed_authorization_contract_v1.dart';

typedef CamoSignedAuthorizationContractV1Verification =
    Future<CamoAuthorizationSignatureVerificationDecision> Function(
      CamoSignedAuthorizationContractV1 contract,
    );

final class CamoSignedAuthorizationContractV1TransportDecoder {
  const CamoSignedAuthorizationContractV1TransportDecoder({
    required this.verifyContract,
  });

  final CamoSignedAuthorizationContractV1Verification verifyContract;

  Future<CamoSignedAuthorizationContractV1> decodeAndVerify({
    required Map<Object?, Object?> payload,
    required String expectedRequestId,
  }) async {
    try {
      if (expectedRequestId.isEmpty) {
        throw StateError('Expected request identifier is unavailable.');
      }

      final CamoSignedAuthorizationContractV1 contract =
          CamoSignedAuthorizationContractV1.parse(payload);

      if (contract.requestId != expectedRequestId) {
        throw StateError('Authorization request binding failed.');
      }

      final CamoAuthorizationSignatureVerificationDecision decision =
          await verifyContract(contract);

      if (!decision.permitsResponseUse) {
        throw StateError('Authorization signature verification was denied.');
      }

      return contract;
    } on Object {
      throw StateError(
        'Signed authorization response verification failed closed.',
      );
    }
  }
}
