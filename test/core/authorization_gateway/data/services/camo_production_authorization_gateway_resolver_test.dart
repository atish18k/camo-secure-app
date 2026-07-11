import 'package:camo/core/authorization_gateway/data/services/default_camo_production_authorization_gateway_resolver.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_response.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_switch_decision.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_gateway.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_gateway_switch.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses fail-closed gateway when production is not requested', () async {
    const _FakeGateway failClosedGateway = _FakeGateway('fail-closed');

    final DefaultCamoProductionAuthorizationGatewayResolver resolver =
        DefaultCamoProductionAuthorizationGatewayResolver(
          gatewaySwitch: const _FakeSwitch(),
          failClosedGateway: failClosedGateway,
        );

    final CamoAuthorizationGatewaySwitchDecision decision = await resolver
        .resolve(productionRequested: false);

    expect(decision.productionActivated, isFalse);
    expect(decision.gateway, same(failClosedGateway));
  });

  test('forwards production request through guarded switch', () async {
    const _FakeGateway failClosedGateway = _FakeGateway('fail-closed');
    const _FakeGateway productionGateway = _FakeGateway('production');

    final DefaultCamoProductionAuthorizationGatewayResolver resolver =
        DefaultCamoProductionAuthorizationGatewayResolver(
          gatewaySwitch: const _FakeSwitch(),
          failClosedGateway: failClosedGateway,
        );

    final CamoAuthorizationGatewaySwitchDecision decision = await resolver
        .resolve(
          productionRequested: true,
          productionGateway: productionGateway,
        );

    expect(decision.productionActivated, isTrue);
    expect(decision.gateway, same(productionGateway));
  });
}

final class _FakeSwitch implements CamoAuthorizationGatewaySwitch {
  const _FakeSwitch();

  @override
  Future<CamoAuthorizationGatewaySwitchDecision> resolve({
    required bool productionRequested,
    required CamoAuthorizationGateway failClosedGateway,
    CamoAuthorizationGateway? productionGateway,
  }) async {
    if (productionRequested && productionGateway != null) {
      return CamoAuthorizationGatewaySwitchDecision.production(
        gateway: productionGateway,
      );
    }

    return CamoAuthorizationGatewaySwitchDecision.failClosed(
      gateway: failClosedGateway,
      reasonCode: 'production_authorization_gateway_not_requested',
    );
  }
}

final class _FakeGateway implements CamoAuthorizationGateway {
  const _FakeGateway(this.name);

  final String name;

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  ) {
    throw UnimplementedError(name);
  }
}
