// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_risk_level.dart';
import '../../../shared/types/camo_security_decision.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoRiskDecision {
  const CamoRiskDecision({
    required this.decisionId,
    required this.riskLevel,
    required this.securityDecision,
    required this.reasonCode,
    required this.score,
    required this.evaluatedAt,
    required this.expiresAt,
  });
  final String decisionId;
  final CamoRiskLevel riskLevel;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final int score;
  final DateTime evaluatedAt;
  final DateTime expiresAt;
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  bool get permitsOperation {
    return securityDecision.isAllowed &&
        !riskLevel.blocksSensitiveOperation &&
        !isExpired;
  }
}
