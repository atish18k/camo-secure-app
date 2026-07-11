// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_entitlement_type.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoEntitlementGrant {
  const CamoEntitlementGrant({
    required this.entitlementType,
    required this.granted,
    required this.reasonCode,
    this.expiresAt,
  });
  final CamoEntitlementType entitlementType;
  final bool granted;
  final String reasonCode;
  final DateTime? expiresAt;
  bool get isExpired {
    final DateTime? expiry = expiresAt;
    return expiry != null && !DateTime.now().isBefore(expiry);
  }

  bool get permitsAccess {
    return granted && !isExpired;
  }
}
