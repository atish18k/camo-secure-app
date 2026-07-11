final class CamoSingleUseAuthorizationArtifact {
  const CamoSingleUseAuthorizationArtifact({
    required this.operationId,
    required this.authorizationId,
    required this.challengeId,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String operationId;
  final String authorizationId;
  final String challengeId;
  final DateTime issuedAt;
  final DateTime expiresAt;

  bool get isStructurallyValid {
    return operationId.trim().isNotEmpty &&
        authorizationId.trim().isNotEmpty &&
        challengeId.trim().isNotEmpty &&
        expiresAt.isAfter(issuedAt);
  }

  bool isExpiredAt(DateTime time) {
    return !time.toUtc().isBefore(expiresAt.toUtc());
  }
}
