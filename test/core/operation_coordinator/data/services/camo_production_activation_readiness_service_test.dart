import 'package:flutter_test/flutter_test.dart';

import 'package:camo/core/operation_coordinator/data/services/default_camo_production_activation_readiness_service.dart';
import 'package:camo/core/operation_coordinator/data/services/fail_closed_camo_production_readiness_probe.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_production_readiness_probe.dart';

void main() {
  group('DefaultCamoProductionActivationReadinessService', () {
    test('fail-closed probe blocks production activation', () async {
      const service = DefaultCamoProductionActivationReadinessService(
        probe: FailClosedCamoProductionReadinessProbe(),
      );

      final readiness = await service.evaluate();

      expect(readiness.permitsProductionActivation, isFalse);
      expect(
        readiness.missingRequirements,
        containsAll(<String>[
          'authorizationGateway',
          'authorizationService',
          'kms',
          'messageContextResolver',
          'serverSignatureVerification',
          'replayProtection',
        ]),
      );
    });

    test('permits activation only when every probe signal is ready', () async {
      const service = DefaultCamoProductionActivationReadinessService(
        probe: _ReadyProductionReadinessProbe(),
      );

      final readiness = await service.evaluate();

      expect(readiness.permitsProductionActivation, isTrue);
      expect(readiness.missingRequirements, isEmpty);
    });

    test('probe failure blocks every production requirement', () async {
      const service = DefaultCamoProductionActivationReadinessService(
        probe: _ThrowingProductionReadinessProbe(),
      );

      final readiness = await service.evaluate();

      expect(readiness.permitsProductionActivation, isFalse);
      expect(readiness.missingRequirements, hasLength(6));
    });
  });
}

final class _ReadyProductionReadinessProbe
    implements CamoProductionReadinessProbe {
  const _ReadyProductionReadinessProbe();

  @override
  Future<bool> isAuthorizationGatewayReady() async => true;

  @override
  Future<bool> isAuthorizationServiceReady() async => true;

  @override
  Future<bool> isKmsReady() async => true;

  @override
  Future<bool> isMessageContextResolverReady() async => true;

  @override
  Future<bool> isServerSignatureVerificationReady() async => true;

  @override
  Future<bool> isReplayProtectionReady() async => true;
}

final class _ThrowingProductionReadinessProbe
    implements CamoProductionReadinessProbe {
  const _ThrowingProductionReadinessProbe();

  Never _fail() {
    throw StateError('Production readiness check unavailable.');
  }

  @override
  Future<bool> isAuthorizationGatewayReady() async => _fail();

  @override
  Future<bool> isAuthorizationServiceReady() async => _fail();

  @override
  Future<bool> isKmsReady() async => _fail();

  @override
  Future<bool> isMessageContextResolverReady() async => _fail();

  @override
  Future<bool> isServerSignatureVerificationReady() async => _fail();

  @override
  Future<bool> isReplayProtectionReady() async => _fail();
}
