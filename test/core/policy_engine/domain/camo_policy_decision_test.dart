// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/policy_engine/domain/entities/camo_policy_decision.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_rule_result.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_rule_status.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoPolicyDecision', () {
    test(
      'allowed unexpired decision without blocking rules permits operation',
      () {
        final DateTime now = DateTime.now();
        final CamoPolicyDecision decision = CamoPolicyDecision(
          decisionId: 'decision-001',
          securityDecision: CamoSecurityDecision.allow,
          reasonCode: 'policy_allowed',
          policyVersion: '1',
          evaluatedAt: now,
          expiresAt: now.add(const Duration(minutes: 1)),
          ruleResults: const <CamoPolicyRuleResult>[
            CamoPolicyRuleResult(
              ruleId: 'session',
              status: CamoPolicyRuleStatus.passed,
              reasonCode: 'session_valid',
              message: 'Session is valid.',
            ),
          ],
        );
        expect(decision.permitsOperation, isTrue);
        expect(decision.hasBlockingRule, isFalse);
      },
    );
    test('blocking rule denies operation', () {
      final DateTime now = DateTime.now();
      final CamoPolicyDecision decision = CamoPolicyDecision(
        decisionId: 'decision-002',
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'rule_failed',
        policyVersion: '1',
        evaluatedAt: now,
        expiresAt: now.add(const Duration(minutes: 1)),
        ruleResults: const <CamoPolicyRuleResult>[
          CamoPolicyRuleResult(
            ruleId: 'subscription',
            status: CamoPolicyRuleStatus.failed,
            reasonCode: 'subscription_inactive',
            message: 'Subscription is inactive.',
          ),
        ],
      );
      expect(decision.permitsOperation, isFalse);
      expect(decision.hasBlockingRule, isTrue);
    });
  });
}
