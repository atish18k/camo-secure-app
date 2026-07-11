import '../../domain/entities/camo_production_activation_readiness.dart';
import '../../domain/services/camo_production_activation_readiness_service.dart';

final class DefaultCamoProductionActivationReadinessService
    implements CamoProductionActivationReadinessService {
  const DefaultCamoProductionActivationReadinessService();

  @override
  Future<CamoProductionActivationReadiness> evaluate() async {
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
