import 'package:camo/core/authorization_gateway/data/services/default_camo_authorization_gateway_switch.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_response.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_gateway.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_production_activation_guard.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'returns fail-closed gateway when production is not requested',
    () async {
      const _FakeGateway failClosedGateway = _FakeGateway('fail-closed');
      const _FakeGateway productionGateway = _FakeGateway('production');

      final DefaultCamoAuthorizationGatewaySwitch gatewaySwitch =
          DefaultCamoAuthorizationGatewaySwitch(
            activationGuard: const _FakeActivationGuard(allowed: true),
          );

      final decision = await gatewaySwitch.resolve(
        productionRequested: false,
        failClosedGateway: failClosedGateway,
        productionGateway: productionGateway,
      );

      expect(decision.productionActivated, isFalse);
      expect(decision.gateway, same(failClosedGateway));
      expect(
        decision.reasonCode,
        'production_authorization_gateway_not_requested',
      );
    },
  );

  test(
    'returns fail-closed gateway when production gateway is absent',
    () async {
      const _FakeGateway failClosedGateway = _FakeGateway('fail-closed');

      final DefaultCamoAuthorizationGatewaySwitch gatewaySwitch =
          DefaultCamoAuthorizationGatewaySwitch(
            activationGuard: const _FakeActivationGuard(allowed: true),
          );

      final decision = await gatewaySwitch.resolve(
        productionRequested: true,
        failClosedGateway: failClosedGateway,
      );

      expect(decision.productionActivated, isFalse);
      expect(decision.gateway, same(failClosedGateway));
      expect(
        decision.reasonCode,
        'production_authorization_gateway_unavailable',
      );
    },
  );

  test('returns fail-closed gateway when readiness guard denies', () async {
    const _FakeGateway failClosedGateway = _FakeGateway('fail-closed');
    const _FakeGateway productionGateway = _FakeGateway('production');

    final DefaultCamoAuthorizationGatewaySwitch gatewaySwitch =
        DefaultCamoAuthorizationGatewaySwitch(
          activationGuard: const _FakeActivationGuard(allowed: false),
        );

    final decision = await gatewaySwitch.resolve(
      productionRequested: true,
      failClosedGateway: failClosedGateway,
      productionGateway: productionGateway,
    );

    expect(decision.productionActivated, isFalse);
    expect(decision.gateway, same(failClosedGateway));
    expect(decision.reasonCode, 'production_activation_readiness_denied');
  });

  test(
    'returns production gateway only when readiness guard permits',
    () async {
      const _FakeGateway failClosedGateway = _FakeGateway('fail-closed');
      const _FakeGateway productionGateway = _FakeGateway('production');

      final DefaultCamoAuthorizationGatewaySwitch gatewaySwitch =
          DefaultCamoAuthorizationGatewaySwitch(
            activationGuard: const _FakeActivationGuard(allowed: true),
          );

      final decision = await gatewaySwitch.resolve(
        productionRequested: true,
        failClosedGateway: failClosedGateway,
        productionGateway: productionGateway,
      );

      expect(decision.productionActivated, isTrue);
      expect(decision.gateway, same(productionGateway));
      expect(decision.reasonCode, 'production_authorization_gateway_activated');
    },
  );
}

final class _FakeActivationGuard implements CamoProductionActivationGuard {
  const _FakeActivationGuard({required this.allowed});

  final bool allowed;

  @override
  Future<void> ensureProductionActivationPermitted() async {
    if (!allowed) {
      throw StateError('Production activation denied.');
    }
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
