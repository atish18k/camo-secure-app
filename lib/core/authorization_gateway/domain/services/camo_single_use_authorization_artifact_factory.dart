import '../entities/camo_single_use_authorization_artifact.dart';

abstract interface class CamoSingleUseAuthorizationArtifactFactory {
  CamoSingleUseAuthorizationArtifact create({
    required String operationId,
    required String authorizationId,
    required String challengeId,
    required DateTime issuedAt,
    required DateTime expiresAt,
  });
}
