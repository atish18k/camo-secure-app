// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/security_session/domain/entities/camo_security_session.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_scope.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_status.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_validation_decision.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('allowed unexpired validation decision permits operation', () {
    final DateTime now = DateTime.now();
    final CamoSecuritySessionValidationDecision decision =
        CamoSecuritySessionValidationDecision(
          decisionId: 'decision-001',
          securityDecision: CamoSecurityDecision.allow,
          reasonCode: 'session_valid',
          session: CamoSecuritySession(
            sessionId: 'session-001',
            userId: 'user-001',
            deviceId: 'device-001',
            scope: CamoSecuritySessionScope.operation,
            status: CamoSecuritySessionStatus.active,
            createdAt: now,
            expiresAt: now.add(const Duration(seconds: 30)),
            lastValidatedAt: now,
            singleUse: true,
            operationId: 'operation-001',
          ),
          evaluatedAt: now,
          expiresAt: now.add(const Duration(seconds: 20)),
          stepUpRequired: false,
        );
    expect(decision.permitsOperation, isTrue);
  });
}
