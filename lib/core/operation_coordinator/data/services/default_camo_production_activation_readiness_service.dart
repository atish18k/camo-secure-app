import '../../domain/entities/camo_production_activation_readiness.dart';
import '../../domain/services/camo_production_activation_readiness_service.dart';
import '../../domain/services/camo_production_readiness_probe.dart';

final class DefaultCamoProductionActivationReadinessService
    implements CamoProductionActivationReadinessService {
  const DefaultCamoProductionActivationReadinessService({required this.probe});

  final CamoProductionReadinessProbe probe;

  @override
  Future<CamoProductionActivationReadiness> evaluate() async {
    try {
      final List<bool> readinessSignals =
          await Future.wait<bool>(<Future<bool>>[
            probe.isAuthorizationGatewayReady(),
            probe.isAuthorizationServiceReady(),
            probe.isKmsReady(),
            probe.isMessageContextResolverReady(),
            probe.isServerSignatureVerificationReady(),
            probe.isReplayProtectionReady(),
          ]);

      return CamoProductionActivationReadiness(
        authorizationGatewayReady: readinessSignals[0],
        authorizationServiceReady: readinessSignals[1],
        kmsReady: readinessSignals[2],
        messageContextResolverReady: readinessSignals[3],
        serverSignatureVerificationReady: readinessSignals[4],
        replayProtectionReady: readinessSignals[5],
      );
    } on Object {
      return const CamoProductionActivationReadiness(
        authorizationGatewayReady: false,
        authorizationServiceReady: false,
        kmsReady: false,
        messageContextResolverReady: false,
        serverSignatureVerificationReady: false,
        replayProtectionReady: false,
      );
    }
  }
}
