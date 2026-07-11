// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/licensing/domain/entities/camo_commercial_access_context.dart';
import 'package:camo/core/licensing/domain/entities/camo_commercial_access_decision.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_grant.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/licensing/domain/entities/camo_license_status.dart';
import 'package:camo/core/licensing/domain/entities/camo_subscription_status.dart';
import 'package:camo/core/licensing/domain/repositories/camo_commercial_security_repository.dart';
import 'package:camo/core/licensing/domain/usecases/validate_camo_commercial_access_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeCommercialSecurityRepository
    implements CamoCommercialSecurityRepository {
  @override
  Future<CamoResult<CamoCommercialAccessDecision>> validateCommercialAccess(
    CamoCommercialAccessContext context,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoCommercialAccessDecision>(
      CamoCommercialAccessDecision(
        decisionId: 'decision-001',
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'commercial_access_allowed',
        evaluatedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        entitlementGrants: context.requiredEntitlements
            .map(
              (CamoEntitlementType entitlement) => CamoEntitlementGrant(
                entitlementType: entitlement,
                granted: true,
                reasonCode: 'entitlement_active',
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('commercial access use case delegates to repository', () async {
    final ValidateCamoCommercialAccessUseCase useCase =
        ValidateCamoCommercialAccessUseCase(
          _FakeCommercialSecurityRepository(),
        );
    final CamoCommercialAccessContext context = CamoCommercialAccessContext(
      userId: 'user-001',
      deviceId: 'device-001',
      operationType: CamoOperationType.decode,
      licenseStatus: CamoLicenseStatus.active,
      subscriptionStatus: CamoSubscriptionStatus.active,
      requestedAt: DateTime.now(),
      requiredEntitlements: const <CamoEntitlementType>{
        CamoEntitlementType.baseDecoding,
      },
    );
    final CamoResult<CamoCommercialAccessDecision> result = await useCase(
      context,
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsOperation, isTrue);
  });
}
