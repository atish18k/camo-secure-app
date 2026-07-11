// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationChallenge {
  const CamoAuthorizationChallenge({
    required this.challengeId,
    required this.challenge,
    required this.issuedAt,
    required this.expiresAt,
  });
  final String challengeId;
  final String challenge;
  final DateTime issuedAt;
  final DateTime expiresAt;
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  bool get isUsable {
    return challengeId.isNotEmpty && challenge.isNotEmpty && !isExpired;
  }
}
