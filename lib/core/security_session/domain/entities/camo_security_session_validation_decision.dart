// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_security_session.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoSecuritySessionValidationDecision {
  const CamoSecuritySessionValidationDecision({
    required this.decisionId,
    required this.securityDecision,
    required this.reasonCode,
    required this.session,
    required this.evaluatedAt,
    required this.expiresAt,
    required this.stepUpRequired,
  });
  final String decisionId;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final CamoSecuritySession session;
  final DateTime evaluatedAt;
  final DateTime expiresAt;
  final bool stepUpRequired;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get permitsOperation {
    return securityDecision.isAllowed &&
        session.isUsable &&
        !stepUpRequired &&
        !isExpired;
  }
}
