// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_key_reference.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoKeyReleaseDecision {
  const CamoKeyReleaseDecision({
    required this.releaseId,
    required this.authorizationId,
    required this.securityDecision,
    required this.reasonCode,
    required this.keyReference,
    required this.issuedAt,
    required this.expiresAt,
    required this.singleUse,
  });
  final String releaseId;
  final String authorizationId;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final CamoKeyReference keyReference;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool singleUse;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get permitsKeyRelease {
    return securityDecision.isAllowed && keyReference.isUsable && !isExpired;
  }
}
