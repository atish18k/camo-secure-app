// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_operation_type.dart';
import 'camo_entitlement_type.dart';
import 'camo_license_status.dart';
import 'camo_subscription_status.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoCommercialAccessContext {
  CamoCommercialAccessContext({
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.licenseStatus,
    required this.subscriptionStatus,
    required this.requestedAt,
    required Set<CamoEntitlementType> requiredEntitlements,
    this.pairId,
    this.messageId,
    Map<String, String> attributes = const <String, String>{},
  }) : requiredEntitlements = Set<CamoEntitlementType>.unmodifiable(
         requiredEntitlements,
       ),
       attributes = Map<String, String>.unmodifiable(attributes);
  final String userId;
  final String deviceId;
  final CamoOperationType operationType;
  final CamoLicenseStatus licenseStatus;
  final CamoSubscriptionStatus subscriptionStatus;
  final DateTime requestedAt;
  final Set<CamoEntitlementType> requiredEntitlements;
  final String? pairId;
  final String? messageId;
  final Map<String, String> attributes;
  bool get hasValidLicense {
    return licenseStatus.isValid;
  }

  bool get hasValidSubscription {
    return subscriptionStatus.permitsBaseAccess;
  }

  bool get requiresCamouflageEntitlement {
    return requiredEntitlements.contains(CamoEntitlementType.camouflage);
  }
}
