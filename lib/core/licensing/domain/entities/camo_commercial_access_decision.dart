// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_entitlement_grant.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoCommercialAccessDecision {
  CamoCommercialAccessDecision({
    required this.decisionId,
    required this.securityDecision,
    required this.reasonCode,
    required this.evaluatedAt,
    required this.expiresAt,
    required List<CamoEntitlementGrant> entitlementGrants,
  }) : entitlementGrants = List<CamoEntitlementGrant>.unmodifiable(
         entitlementGrants,
       );
  final String decisionId;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final DateTime evaluatedAt;
  final DateTime expiresAt;
  final List<CamoEntitlementGrant> entitlementGrants;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get hasDeniedEntitlement {
    return entitlementGrants.any(
      (CamoEntitlementGrant grant) => !grant.permitsAccess,
    );
  }

  bool get permitsOperation {
    return securityDecision.isAllowed && !hasDeniedEntitlement && !isExpired;
  }
}
