// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/camo_authorization_gateway_switch_decision.dart';
import '../../domain/services/camo_authorization_gateway.dart';
import '../../domain/services/camo_authorization_gateway_switch.dart';
import '../../domain/services/camo_production_authorization_gateway_resolver.dart';

final class DefaultCamoProductionAuthorizationGatewayResolver
    implements CamoProductionAuthorizationGatewayResolver {
  const DefaultCamoProductionAuthorizationGatewayResolver({
    required CamoAuthorizationGatewaySwitch gatewaySwitch,
    required CamoAuthorizationGateway failClosedGateway,
  }) : _gatewaySwitch = gatewaySwitch,
       _failClosedGateway = failClosedGateway;

  final CamoAuthorizationGatewaySwitch _gatewaySwitch;
  final CamoAuthorizationGateway _failClosedGateway;

  @override
  Future<CamoAuthorizationGatewaySwitchDecision> resolve({
    required bool productionRequested,
    CamoAuthorizationGateway? productionGateway,
  }) {
    return _gatewaySwitch.resolve(
      productionRequested: productionRequested,
      failClosedGateway: _failClosedGateway,
      productionGateway: productionGateway,
    );
  }
}
