import '../entities/camo_single_use_authorization_artifact.dart';

abstract interface class CamoSingleUseAuthorizationStore {
  Future<bool> consume(CamoSingleUseAuthorizationArtifact artifact);

  Future<void> clearExpired(DateTime currentTime);
}
