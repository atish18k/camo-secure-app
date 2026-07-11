// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/licensing/domain/entities/camo_commercial_access_context.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/licensing/domain/entities/camo_license_status.dart';
import 'package:camo/core/licensing/domain/entities/camo_subscription_status.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoCommercialAccessContext', () {
    test('active license and subscription are valid', () {
      final CamoCommercialAccessContext context = CamoCommercialAccessContext(
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.encode,
        licenseStatus: CamoLicenseStatus.active,
        subscriptionStatus: CamoSubscriptionStatus.active,
        requestedAt: DateTime.utc(2026, 7, 11),
        requiredEntitlements: const <CamoEntitlementType>{
          CamoEntitlementType.baseEncoding,
        },
      );
      expect(context.hasValidLicense, isTrue);
      expect(context.hasValidSubscription, isTrue);
      expect(context.requiresCamouflageEntitlement, isFalse);
    });
    test('camouflage is treated as a separate entitlement', () {
      final CamoCommercialAccessContext context = CamoCommercialAccessContext(
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.encode,
        licenseStatus: CamoLicenseStatus.active,
        subscriptionStatus: CamoSubscriptionStatus.active,
        requestedAt: DateTime.utc(2026, 7, 11),
        requiredEntitlements: const <CamoEntitlementType>{
          CamoEntitlementType.baseEncoding,
          CamoEntitlementType.camouflage,
        },
      );
      expect(context.requiresCamouflageEntitlement, isTrue);
    });
  });
}
