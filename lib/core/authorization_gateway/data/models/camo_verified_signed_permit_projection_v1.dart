import 'camo_signed_authorization_contract_v1.dart';

final class CamoVerifiedSignedPermitProjectionV1 {
  const CamoVerifiedSignedPermitProjectionV1({
    required this.requestId,
    required this.authorizationId,
    required this.operationId,
    required this.challengeId,
    required this.userId,
    required this.deviceId,
    required this.keyReleaseId,
    required this.keyReference,
    required this.sessionId,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
    this.pairId,
    this.messageId,
  });

  factory CamoVerifiedSignedPermitProjectionV1.fromVerifiedContract(
    CamoSignedAuthorizationContractV1 contract,
  ) {
    if (!contract.authorized ||
        !contract.isWithinValidityWindow ||
        contract.signature.trim().isEmpty) {
      throw StateError('Verified signed permit contract is unusable.');
    }

    return CamoVerifiedSignedPermitProjectionV1(
      requestId: contract.requestId,
      authorizationId: contract.authorizationId,
      operationId: contract.operationId,
      challengeId: contract.challengeId,
      userId: contract.userId,
      deviceId: contract.deviceId,
      pairId: contract.pairId,
      messageId: contract.messageId,
      keyReleaseId: contract.keyReleaseId,
      keyReference: contract.keyReference,
      sessionId: contract.sessionId,
      issuedAt: contract.issuedAt,
      expiresAt: contract.expiresAt,
      signature: contract.signature,
    );
  }

  final String requestId;
  final String authorizationId;
  final String operationId;
  final String challengeId;
  final String userId;
  final String deviceId;
  final String? pairId;
  final String? messageId;
  final String keyReleaseId;
  final String keyReference;
  final String sessionId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String signature;

  bool get isStructurallyValid {
    return requestId.trim().isNotEmpty &&
        authorizationId.trim().isNotEmpty &&
        operationId.trim().isNotEmpty &&
        challengeId.trim().isNotEmpty &&
        userId.trim().isNotEmpty &&
        deviceId.trim().isNotEmpty &&
        keyReleaseId.trim().isNotEmpty &&
        keyReference.trim().isNotEmpty &&
        sessionId.trim().isNotEmpty &&
        signature.trim().isNotEmpty &&
        expiresAt.isAfter(issuedAt);
  }
}
