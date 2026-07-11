// ignore_for_file: prefer_initializing_formals

import '../../../operation_coordinator/domain/services/camo_production_activation_guard.dart';
import '../../domain/entities/camo_authorization_gateway_switch_decision.dart';
import '../../domain/services/camo_authorization_gateway.dart';
import '../../domain/services/camo_authorization_gateway_switch.dart';

final class DefaultCamoAuthorizationGatewaySwitch
    implements CamoAuthorizationGatewaySwitch {
  const DefaultCamoAuthorizationGatewaySwitch({
    required CamoProductionActivationGuard activationGuard,
  }) : _activationGuard = activationGuard;

  final CamoProductionActivationGuard _activationGuard;

  @override
  Future<CamoAuthorizationGatewaySwitchDecision> resolve({
    required bool productionRequested,
    required CamoAuthorizationGateway failClosedGateway,
    CamoAuthorizationGateway? productionGateway,
  }) async {
    if (!productionRequested) {
      return CamoAuthorizationGatewaySwitchDecision.failClosed(
        gateway: failClosedGateway,
        reasonCode: 'production_authorization_gateway_not_requested',
      );
    }

    if (productionGateway == null) {
      return CamoAuthorizationGatewaySwitchDecision.failClosed(
        gateway: failClosedGateway,
        reasonCode: 'production_authorization_gateway_unavailable',
      );
    }

    try {
      await _activationGuard.ensureProductionActivationPermitted();

      return CamoAuthorizationGatewaySwitchDecision.production(
        gateway: productionGateway,
      );
    } catch (_) {
      return CamoAuthorizationGatewaySwitchDecision.failClosed(
        gateway: failClosedGateway,
        reasonCode: 'production_activation_readiness_denied',
      );
    }
  }
}
