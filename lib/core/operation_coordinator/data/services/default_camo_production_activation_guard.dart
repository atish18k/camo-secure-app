// ignore_for_file: prefer_initializing_formals

import '../../domain/services/camo_production_activation_guard.dart';
import '../../domain/services/camo_production_activation_readiness_service.dart';

final class DefaultCamoProductionActivationGuard
    implements CamoProductionActivationGuard {
  const DefaultCamoProductionActivationGuard({
    required CamoProductionActivationReadinessService readinessService,
  }) : _readinessService = readinessService;

  final CamoProductionActivationReadinessService _readinessService;

  @override
  Future<void> ensureProductionActivationPermitted() async {
    final readiness = await _readinessService.evaluate();

    if (!readiness.permitsProductionActivation) {
      final String missing = readiness.missingRequirements.join(', ');

      throw StateError(
        'CAMO production authorization activation is blocked. '
        'Missing verified components: $missing.',
      );
    }
  }
}
