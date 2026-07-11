// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/licensing/domain/entities/camo_commercial_access_decision.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_grant.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoCommercialAccessDecision', () {
    test('allowed decision with valid grants permits operation', () {
      final DateTime now = DateTime.now();
      final CamoCommercialAccessDecision decision =
          CamoCommercialAccessDecision(
            decisionId: 'decision-001',
            securityDecision: CamoSecurityDecision.allow,
            reasonCode: 'commercial_access_allowed',
            evaluatedAt: now,
            expiresAt: now.add(const Duration(minutes: 1)),
            entitlementGrants: const <CamoEntitlementGrant>[
              CamoEntitlementGrant(
                entitlementType: CamoEntitlementType.baseEncoding,
                granted: true,
                reasonCode: 'entitlement_active',
              ),
            ],
          );
      expect(decision.permitsOperation, isTrue);
      expect(decision.hasDeniedEntitlement, isFalse);
    });
    test('missing camouflage grant denies operation', () {
      final DateTime now = DateTime.now();
      final CamoCommercialAccessDecision decision =
          CamoCommercialAccessDecision(
            decisionId: 'decision-002',
            securityDecision: CamoSecurityDecision.allow,
            reasonCode: 'entitlement_missing',
            evaluatedAt: now,
            expiresAt: now.add(const Duration(minutes: 1)),
            entitlementGrants: const <CamoEntitlementGrant>[
              CamoEntitlementGrant(
                entitlementType: CamoEntitlementType.camouflage,
                granted: false,
                reasonCode: 'camouflage_not_purchased',
              ),
            ],
          );
      expect(decision.permitsOperation, isFalse);
      expect(decision.hasDeniedEntitlement, isTrue);
    });
  });
}
