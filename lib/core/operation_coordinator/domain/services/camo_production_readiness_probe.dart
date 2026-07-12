/// Provides independently evaluated production-component readiness signals.
///
/// A probe reports readiness only. It must not activate production services,
/// replace fail-closed bindings or perform an authorization operation.
abstract interface class CamoProductionReadinessProbe {
  Future<bool> isAuthorizationGatewayReady();

  Future<bool> isAuthorizationServiceReady();

  Future<bool> isKmsReady();

  Future<bool> isMessageContextResolverReady();

  Future<bool> isServerSignatureVerificationReady();

  Future<bool> isReplayProtectionReady();
}
