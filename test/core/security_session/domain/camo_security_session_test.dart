// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/security_session/domain/entities/camo_security_session.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_scope.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_status.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoSecuritySession', () {
    test('active unexpired operation-bound session is usable', () {
      final DateTime now = DateTime.now();
      final CamoSecuritySession session = CamoSecuritySession(
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
        authorizationId: 'authorization-001',
      );
      expect(session.isUsable, isTrue);
      expect(session.hasValidIdentityBinding, isTrue);
      expect(session.hasValidOperationBinding, isTrue);
    });
    test('operation-bound session without operation id is unusable', () {
      final DateTime now = DateTime.now();
      final CamoSecuritySession session = CamoSecuritySession(
        sessionId: 'session-002',
        userId: 'user-001',
        deviceId: 'device-001',
        scope: CamoSecuritySessionScope.operation,
        status: CamoSecuritySessionStatus.active,
        createdAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        lastValidatedAt: now,
        singleUse: true,
      );
      expect(session.isUsable, isFalse);
      expect(session.hasValidOperationBinding, isFalse);
    });
  });
}
