// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/camo_single_use_authorization_artifact.dart';
import '../../domain/entities/camo_single_use_consumption_decision.dart';
import '../../domain/repositories/camo_single_use_authorization_store.dart';
import '../../domain/services/camo_single_use_authorization_service.dart';

final class DefaultCamoSingleUseAuthorizationService
    implements CamoSingleUseAuthorizationService {
  const DefaultCamoSingleUseAuthorizationService({
    required CamoSingleUseAuthorizationStore store,
    required DateTime Function() clock,
  }) : _store = store,
       _clock = clock;

  final CamoSingleUseAuthorizationStore _store;
  final DateTime Function() _clock;

  @override
  Future<CamoSingleUseConsumptionDecision> consume(
    CamoSingleUseAuthorizationArtifact artifact,
  ) async {
    if (!artifact.isStructurallyValid) {
      return const CamoSingleUseConsumptionDecision.denied(
        'single_use_authorization_artifact_invalid',
      );
    }

    final DateTime currentTime = _clock().toUtc();

    if (artifact.isExpiredAt(currentTime)) {
      return const CamoSingleUseConsumptionDecision.denied(
        'single_use_authorization_artifact_expired',
      );
    }

    try {
      await _store.clearExpired(currentTime);

      final bool consumed = await _store.consume(artifact);

      if (!consumed) {
        return const CamoSingleUseConsumptionDecision.denied(
          'single_use_authorization_replay_detected',
        );
      }

      return const CamoSingleUseConsumptionDecision.consumed();
    } catch (_) {
      return const CamoSingleUseConsumptionDecision.denied(
        'single_use_authorization_store_unavailable',
      );
    }
  }
}
