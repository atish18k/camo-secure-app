// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationToken {
  const CamoAuthorizationToken({
    required this.tokenId,
    required this.authorizationId,
    required this.operationId,
    required this.userId,
    required this.deviceId,
    required this.issuedAt,
    required this.expiresAt,
    required this.singleUse,
    required this.signature,
    this.pairId,
    this.messageId,
  });
  final String tokenId;
  final String authorizationId;
  final String operationId;
  final String userId;
  final String deviceId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool singleUse;
  final String signature;
  final String? pairId;
  final String? messageId;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get hasValidSignature {
    return signature.isNotEmpty;
  }

  bool get isUsable {
    return tokenId.isNotEmpty &&
        authorizationId.isNotEmpty &&
        operationId.isNotEmpty &&
        userId.isNotEmpty &&
        deviceId.isNotEmpty &&
        hasValidSignature &&
        !isExpired;
  }
}
