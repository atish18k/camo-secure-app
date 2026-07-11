import '../entities/camo_authorization_gateway_switch_decision.dart';
import 'camo_authorization_gateway.dart';

abstract interface class CamoAuthorizationGatewaySwitch {
  Future<CamoAuthorizationGatewaySwitchDecision> resolve({
    required bool productionRequested,
    required CamoAuthorizationGateway failClosedGateway,
    CamoAuthorizationGateway? productionGateway,
  });
}
