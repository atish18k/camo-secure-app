import '../../../crypto/server_share/camo_server_share.dart';
import 'camo_signed_authorization_contract_v2.dart';

final class CamoVerifiedSignedPermitProjectionV2 {
  CamoVerifiedSignedPermitProjectionV2._({
    required this.requestId,
    required this.authorizationId,
    required this.operationId,
    required this.challengeId,
    required this.userId,
    required this.deviceId,
    required this.pairId,
    required this.messageId,
    required this.sessionId,
    required this.keyReleaseId,
    required this.keyReference,
    required this.issuedAt,
    required this.serverShare,
    required this.expiresAt,
    required this.signingKeyId,
    required this.signature,
  });

  final String requestId;
  final String authorizationId;
  final String operationId;
  final String challengeId;
  final String userId;
  final String deviceId;
  final String pairId;
  final String messageId;
  final String sessionId;
  final String keyReleaseId;
  final String keyReference;
  final DateTime issuedAt;
  final CamoServerShare serverShare;
  final DateTime expiresAt;
  final String signingKeyId;
  final String signature;

  bool get isValid {
    return requestId.trim().isNotEmpty &&
        authorizationId.trim().isNotEmpty &&
        operationId.trim().isNotEmpty &&
        challengeId.trim().isNotEmpty &&
        userId.trim().isNotEmpty &&
        deviceId.trim().isNotEmpty &&
        pairId.trim().isNotEmpty &&
        messageId.trim().isNotEmpty &&
        sessionId.trim().isNotEmpty &&
        keyReleaseId.trim().isNotEmpty &&
        keyReference.trim().isNotEmpty &&
        signingKeyId.trim().isNotEmpty &&
        signature.trim().isNotEmpty &&
        expiresAt.toUtc().isAfter(issuedAt.toUtc()) &&
        serverShare.operationId.trim() == operationId.trim();
  }

  factory CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(
    CamoSignedAuthorizationContractV2 contract,
  ) {
    return CamoVerifiedSignedPermitProjectionV2._(
      requestId: contract.requestId,
      authorizationId: contract.authorizationId,
      operationId: contract.operationId,
      challengeId: contract.challengeId,
      userId: contract.userId,
      deviceId: contract.deviceId,
      pairId: contract.pairId,
      messageId: contract.messageId,
      sessionId: contract.sessionId,
      keyReleaseId: contract.keyReleaseId,
      keyReference: contract.keyReference,
      issuedAt: contract.issuedAt,
      serverShare: CamoServerShare(
        shareId: contract.serverShareId,
        operationId: contract.operationId,
        version: contract.serverShareVersion,
        expiresAt: contract.serverShareExpiresAt,
        bytes: contract.decodeServerShareBytes(),
      ),
      expiresAt: contract.expiresAt,
      signingKeyId: contract.signingKeyId,
      signature: contract.signature,
    );
  }
}
