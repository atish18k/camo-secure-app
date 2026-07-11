// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_authorization_status.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationDecision {
  const CamoAuthorizationDecision({
    required this.authorizationId,
    required this.status,
    required this.securityDecision,
    required this.reasonCode,
    required this.issuedAt,
    required this.expiresAt,
  });
  final String authorizationId;
  final CamoAuthorizationStatus status;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final DateTime issuedAt;
  final DateTime expiresAt;
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  bool get permitsOperation {
    return status.permitsOperation && securityDecision.isAllowed && !isExpired;
  }
}
