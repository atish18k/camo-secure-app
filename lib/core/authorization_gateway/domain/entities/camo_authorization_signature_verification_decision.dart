final class CamoAuthorizationSignatureVerificationDecision {
  const CamoAuthorizationSignatureVerificationDecision._({
    required this.verified,
    required this.reasonCode,
  });

  const CamoAuthorizationSignatureVerificationDecision.verified()
    : this._(
        verified: true,
        reasonCode: 'authorization_response_signature_verified',
      );

  const CamoAuthorizationSignatureVerificationDecision.denied(String reasonCode)
    : this._(verified: false, reasonCode: reasonCode);

  final bool verified;
  final String reasonCode;

  bool get permitsResponseUse {
    return verified && reasonCode.trim().isNotEmpty;
  }
}
