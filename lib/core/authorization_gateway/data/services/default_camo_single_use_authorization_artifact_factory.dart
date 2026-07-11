import '../../domain/entities/camo_single_use_authorization_artifact.dart';
import '../../domain/services/camo_single_use_authorization_artifact_factory.dart';

final class DefaultCamoSingleUseAuthorizationArtifactFactory
    implements CamoSingleUseAuthorizationArtifactFactory {
  const DefaultCamoSingleUseAuthorizationArtifactFactory();

  @override
  CamoSingleUseAuthorizationArtifact create({
    required String operationId,
    required String authorizationId,
    required String challengeId,
    required DateTime issuedAt,
    required DateTime expiresAt,
  }) {
    final CamoSingleUseAuthorizationArtifact artifact =
        CamoSingleUseAuthorizationArtifact(
          operationId: operationId.trim(),
          authorizationId: authorizationId.trim(),
          challengeId: challengeId.trim(),
          issuedAt: issuedAt.toUtc(),
          expiresAt: expiresAt.toUtc(),
        );

    if (!artifact.isStructurallyValid) {
      throw StateError(
        'Single-use authorization artifact could not be created.',
      );
    }

    return artifact;
  }
}
