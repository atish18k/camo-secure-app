import '../../domain/entities/camo_single_use_authorization_artifact.dart';
import '../../domain/repositories/camo_single_use_authorization_store.dart';

final class CamoMemorySingleUseAuthorizationStore
    implements CamoSingleUseAuthorizationStore {
  final Map<String, DateTime> _operationIds = <String, DateTime>{};
  final Map<String, DateTime> _authorizationIds = <String, DateTime>{};
  final Map<String, DateTime> _challengeIds = <String, DateTime>{};

  @override
  Future<bool> consume(CamoSingleUseAuthorizationArtifact artifact) async {
    final String operationId = artifact.operationId.trim();
    final String authorizationId = artifact.authorizationId.trim();
    final String challengeId = artifact.challengeId.trim();

    if (_operationIds.containsKey(operationId) ||
        _authorizationIds.containsKey(authorizationId) ||
        _challengeIds.containsKey(challengeId)) {
      return false;
    }

    final DateTime expiry = artifact.expiresAt.toUtc();

    _operationIds[operationId] = expiry;
    _authorizationIds[authorizationId] = expiry;
    _challengeIds[challengeId] = expiry;

    return true;
  }

  @override
  Future<void> clearExpired(DateTime currentTime) async {
    final DateTime normalizedTime = currentTime.toUtc();

    _operationIds.removeWhere(
      (String _, DateTime expiry) => !normalizedTime.isBefore(expiry),
    );

    _authorizationIds.removeWhere(
      (String _, DateTime expiry) => !normalizedTime.isBefore(expiry),
    );

    _challengeIds.removeWhere(
      (String _, DateTime expiry) => !normalizedTime.isBefore(expiry),
    );
  }
}
