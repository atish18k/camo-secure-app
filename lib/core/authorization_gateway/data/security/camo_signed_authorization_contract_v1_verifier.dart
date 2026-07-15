import 'dart:convert';

import '../../domain/entities/camo_authorization_signature_verification_decision.dart';
import '../models/camo_signed_authorization_contract_v1.dart';
import '../services/camo_signed_authorization_contract_v1_canonicalizer.dart';
import 'camo_p256_der_signature_decoder.dart';
import 'camo_p256_signature_verification_primitive.dart';
import 'camo_pinned_authorization_public_key_v1.dart';

final class CamoSignedAuthorizationContractV1Verifier {
  const CamoSignedAuthorizationContractV1Verifier({
    required this.canonicalizer,
    required this.derDecoder,
    required this.pinnedKey,
    required this.primitive,
    required this.clock,
    this.maximumFutureSkew = const Duration(seconds: 30),
  });

  final CamoSignedAuthorizationContractV1Canonicalizer canonicalizer;
  final CamoP256DerSignatureDecoder derDecoder;
  final CamoPinnedAuthorizationPublicKeyV1 pinnedKey;
  final CamoP256SignatureVerificationPrimitive primitive;
  final DateTime Function() clock;
  final Duration maximumFutureSkew;

  Future<CamoAuthorizationSignatureVerificationDecision> verify(
    CamoSignedAuthorizationContractV1 contract,
  ) async {
    try {
      if (contract.signingKeyId !=
          CamoPinnedAuthorizationPublicKeyV1.signingKeyId) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_signing_key_not_pinned',
        );
      }

      if (contract.signatureAlgorithm !=
          CamoPinnedAuthorizationPublicKeyV1.algorithm) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_signature_algorithm_invalid',
        );
      }

      if (contract.reasonCode != 'server_authorization_granted') {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_reason_code_invalid',
        );
      }

      final DateTime now = clock().toUtc();

      if (contract.issuedAt.isAfter(now.add(maximumFutureSkew))) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_response_not_yet_valid',
        );
      }

      if (!now.isBefore(contract.expiresAt)) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_response_expired',
        );
      }

      if (!await pinnedKey.hasValidSpkiSha256()) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_public_key_integrity_failed',
        );
      }

      final String canonicalPayload = canonicalizer.canonicalize(contract);

      final List<int> rawSignature = derDecoder.decode(
        contract.decodeDerSignature(),
      );

      final bool verified = await primitive.verify(
        message: List<int>.unmodifiable(utf8.encode(canonicalPayload)),
        rawSignature: rawSignature,
        publicKeyX: pinnedKey.x,
        publicKeyY: pinnedKey.y,
      );

      if (!verified) {
        return const CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_signature_invalid',
        );
      }

      return const CamoAuthorizationSignatureVerificationDecision.verified();
    } on Object {
      return const CamoAuthorizationSignatureVerificationDecision.denied(
        'authorization_signature_verification_failed',
      );
    }
  }
}
