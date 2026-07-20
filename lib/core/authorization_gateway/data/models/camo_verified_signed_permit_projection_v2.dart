import '../../../crypto/server_share/camo_server_share.dart';
import 'camo_signed_authorization_contract_v2.dart';

final class CamoVerifiedSignedPermitProjectionV2 {
  CamoVerifiedSignedPermitProjectionV2._({
    required this.authorizationId,
    required this.operationId,
    required this.challengeId,
    required this.messageId,
    required this.serverShare,
    required this.expiresAt,
    required this.signingKeyId,
  });

  final String authorizationId;
  final String operationId;
  final String challengeId;
  final String messageId;
  final CamoServerShare serverShare;
  final DateTime expiresAt;
  final String signingKeyId;

  factory CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(
    CamoSignedAuthorizationContractV2 contract,
  ) {
    return CamoVerifiedSignedPermitProjectionV2._(
      authorizationId: contract.authorizationId,
      operationId: contract.operationId,
      challengeId: contract.challengeId,
      messageId: contract.messageId,
      serverShare: CamoServerShare(
        shareId: contract.serverShareId,
        operationId: contract.operationId,
        version: contract.serverShareVersion,
        expiresAt: contract.serverShareExpiresAt,
        bytes: contract.decodeServerShareBytes(),
      ),
      expiresAt: contract.expiresAt,
      signingKeyId: contract.signingKeyId,
    );
  }
}
