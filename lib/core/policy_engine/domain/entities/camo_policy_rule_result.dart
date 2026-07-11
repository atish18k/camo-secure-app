// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_policy_rule_status.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoPolicyRuleResult {
  const CamoPolicyRuleResult({
    required this.ruleId,
    required this.status,
    required this.reasonCode,
    required this.message,
  });
  final String ruleId;
  final CamoPolicyRuleStatus status;
  final String reasonCode;
  final String message;
  bool get blocksOperation => status.isBlocking;
  bool get requiresStepUp => status.requiresStepUp;
}
