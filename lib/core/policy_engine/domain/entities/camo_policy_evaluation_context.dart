// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_device_trust_level.dart';
import '../../../shared/types/camo_operation_type.dart';
import '../../../shared/types/camo_risk_level.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoPolicyEvaluationContext {
  CamoPolicyEvaluationContext({
    required this.operationId,
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.deviceTrustLevel,
    required this.riskLevel,
    required this.sessionValid,
    required this.pairValid,
    required this.licenseValid,
    required this.subscriptionValid,
    required this.entitlementValid,
    required this.messageValid,
    required this.evaluatedAt,
    this.pairId,
    this.messageId,
    Map<String, String> attributes = const <String, String>{},
  }) : attributes = Map<String, String>.unmodifiable(attributes);
  final String operationId;
  final String userId;
  final String deviceId;
  final CamoOperationType operationType;
  final CamoDeviceTrustLevel deviceTrustLevel;
  final CamoRiskLevel riskLevel;
  final bool sessionValid;
  final bool pairValid;
  final bool licenseValid;
  final bool subscriptionValid;
  final bool entitlementValid;
  final bool messageValid;
  final DateTime evaluatedAt;
  final String? pairId;
  final String? messageId;
  final Map<String, String> attributes;
  bool get hasValidIdentityContext {
    return userId.isNotEmpty && deviceId.isNotEmpty && sessionValid;
  }

  bool get hasValidCommercialContext {
    return licenseValid && subscriptionValid && entitlementValid;
  }

  bool get hasValidOperationContext {
    return pairValid && messageValid;
  }
}
