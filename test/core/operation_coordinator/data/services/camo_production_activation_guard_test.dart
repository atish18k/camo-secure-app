import 'package:camo/core/operation_coordinator/data/services/default_camo_production_activation_guard.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_production_activation_readiness.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_production_activation_readiness_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('blocks production activation when any requirement is missing', () {
    final DefaultCamoProductionActivationGuard guard =
        DefaultCamoProductionActivationGuard(
          readinessService: const _FakeReadinessService(
            CamoProductionActivationReadiness(
              authorizationGatewayReady: true,
              authorizationServiceReady: true,
              kmsReady: false,
              messageContextResolverReady: true,
              serverSignatureVerificationReady: true,
              replayProtectionReady: true,
            ),
          ),
        );

    expect(
      guard.ensureProductionActivationPermitted,
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          contains('kms'),
        ),
      ),
    );
  });

  test('permits activation only when every requirement is ready', () async {
    final DefaultCamoProductionActivationGuard guard =
        DefaultCamoProductionActivationGuard(
          readinessService: const _FakeReadinessService(
            CamoProductionActivationReadiness(
              authorizationGatewayReady: true,
              authorizationServiceReady: true,
              kmsReady: true,
              messageContextResolverReady: true,
              serverSignatureVerificationReady: true,
              replayProtectionReady: true,
            ),
          ),
        );

    await expectLater(guard.ensureProductionActivationPermitted(), completes);
  });

  test('reports every missing production requirement', () {
    const CamoProductionActivationReadiness readiness =
        CamoProductionActivationReadiness(
          authorizationGatewayReady: false,
          authorizationServiceReady: false,
          kmsReady: false,
          messageContextResolverReady: false,
          serverSignatureVerificationReady: false,
          replayProtectionReady: false,
        );

    expect(readiness.permitsProductionActivation, isFalse);
    expect(readiness.missingRequirements, hasLength(6));
  });
}

final class _FakeReadinessService
    implements CamoProductionActivationReadinessService {
  const _FakeReadinessService(this.readiness);

  final CamoProductionActivationReadiness readiness;

  @override
  Future<CamoProductionActivationReadiness> evaluate() async {
    return readiness;
  }
}
