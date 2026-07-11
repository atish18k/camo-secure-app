// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_security_decision.dart';
import 'camo_policy_rule_result.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoPolicyDecision {
  CamoPolicyDecision({
    required this.decisionId,
    required this.securityDecision,
    required this.reasonCode,
    required this.policyVersion,
    required this.evaluatedAt,
    required this.expiresAt,
    required List<CamoPolicyRuleResult> ruleResults,
  }) : ruleResults = List<CamoPolicyRuleResult>.unmodifiable(ruleResults);
  final String decisionId;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final String policyVersion;
  final DateTime evaluatedAt;
  final DateTime expiresAt;
  final List<CamoPolicyRuleResult> ruleResults;
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  bool get hasBlockingRule {
    return ruleResults.any(
      (CamoPolicyRuleResult result) => result.blocksOperation,
    );
  }

  bool get permitsOperation {
    return securityDecision.isAllowed && !hasBlockingRule && !isExpired;
  }
}
