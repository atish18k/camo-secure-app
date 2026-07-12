import '../../domain/services/camo_production_readiness_probe.dart';

/// Safe runtime probe used until every production component has an
/// independently verified implementation.
///
/// Every signal remains false so partial infrastructure can never activate
/// the production Authorization Gateway.
final class FailClosedCamoProductionReadinessProbe
    implements CamoProductionReadinessProbe {
  const FailClosedCamoProductionReadinessProbe();

  @override
  Future<bool> isAuthorizationGatewayReady() async => false;

  @override
  Future<bool> isAuthorizationServiceReady() async => false;

  @override
  Future<bool> isKmsReady() async => false;

  @override
  Future<bool> isMessageContextResolverReady() async => false;

  @override
  Future<bool> isServerSignatureVerificationReady() async => false;

  @override
  Future<bool> isReplayProtectionReady() async => false;
}
