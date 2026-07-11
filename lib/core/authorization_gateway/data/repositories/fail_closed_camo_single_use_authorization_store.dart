import '../../domain/entities/camo_single_use_authorization_artifact.dart';
import '../../domain/repositories/camo_single_use_authorization_store.dart';

final class FailClosedCamoSingleUseAuthorizationStore
    implements CamoSingleUseAuthorizationStore {
  const FailClosedCamoSingleUseAuthorizationStore();

  @override
  Future<bool> consume(CamoSingleUseAuthorizationArtifact artifact) {
    throw StateError(
      'Production replay-protection persistence is unavailable.',
    );
  }

  @override
  Future<void> clearExpired(DateTime currentTime) {
    throw StateError(
      'Production replay-protection persistence is unavailable.',
    );
  }
}
