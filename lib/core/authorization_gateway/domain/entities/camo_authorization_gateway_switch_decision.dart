import '../services/camo_authorization_gateway.dart';

final class CamoAuthorizationGatewaySwitchDecision {
  const CamoAuthorizationGatewaySwitchDecision._({
    required this.gateway,
    required this.productionActivated,
    required this.reasonCode,
  });

  const CamoAuthorizationGatewaySwitchDecision.production({
    required CamoAuthorizationGateway gateway,
  }) : this._(
         gateway: gateway,
         productionActivated: true,
         reasonCode: 'production_authorization_gateway_activated',
       );

  const CamoAuthorizationGatewaySwitchDecision.failClosed({
    required CamoAuthorizationGateway gateway,
    required String reasonCode,
  }) : this._(
         gateway: gateway,
         productionActivated: false,
         reasonCode: reasonCode,
       );

  final CamoAuthorizationGateway gateway;
  final bool productionActivated;
  final String reasonCode;

  bool get isValid {
    return reasonCode.trim().isNotEmpty;
  }
}
