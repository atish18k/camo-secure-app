final class CamoProductionActivationReadiness {
  const CamoProductionActivationReadiness({
    required this.authorizationGatewayReady,
    required this.authorizationServiceReady,
    required this.kmsReady,
    required this.messageContextResolverReady,
    required this.serverSignatureVerificationReady,
    required this.replayProtectionReady,
  });

  final bool authorizationGatewayReady;
  final bool authorizationServiceReady;
  final bool kmsReady;
  final bool messageContextResolverReady;
  final bool serverSignatureVerificationReady;
  final bool replayProtectionReady;

  bool get permitsProductionActivation {
    return authorizationGatewayReady &&
        authorizationServiceReady &&
        kmsReady &&
        messageContextResolverReady &&
        serverSignatureVerificationReady &&
        replayProtectionReady;
  }

  List<String> get missingRequirements {
    return <String>[
      if (!authorizationGatewayReady) 'authorizationGateway',
      if (!authorizationServiceReady) 'authorizationService',
      if (!kmsReady) 'kms',
      if (!messageContextResolverReady) 'messageContextResolver',
      if (!serverSignatureVerificationReady) 'serverSignatureVerification',
      if (!replayProtectionReady) 'replayProtection',
    ];
  }
}
