// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_authorization_decision.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_status.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoAuthorizationDecision', () {
    test('permits a valid allowed authorization', () {
      final DateTime now = DateTime.now();
      final CamoAuthorizationDecision decision = CamoAuthorizationDecision(
        authorizationId: 'authorization-001',
        status: CamoAuthorizationStatus.allowed,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'authorized',
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 1)),
      );
      expect(decision.permitsOperation, isTrue);
      expect(decision.isExpired, isFalse);
    });
    test('rejects an expired authorization', () {
      final DateTime now = DateTime.now();
      final CamoAuthorizationDecision decision = CamoAuthorizationDecision(
        authorizationId: 'authorization-002',
        status: CamoAuthorizationStatus.allowed,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'authorized',
        issuedAt: now.subtract(const Duration(minutes: 2)),
        expiresAt: now.subtract(const Duration(minutes: 1)),
      );
      expect(decision.permitsOperation, isFalse);
      expect(decision.isExpired, isTrue);
    });
  });
}
