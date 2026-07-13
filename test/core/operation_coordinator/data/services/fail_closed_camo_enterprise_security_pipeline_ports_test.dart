import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/operation_coordinator/data/services/fail_closed_camo_enterprise_security_pipeline_ports.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 7, 13);

  final CamoEnterpriseOperationRequest request = CamoEnterpriseOperationRequest(
    requestId: 'request-001',
    authorizationRequest: CamoEnterpriseAuthorizationRequest(
      operationId: 'operation-001',
      userId: 'user-001',
      deviceId: 'device-001',
      operationType: CamoOperationType.encode,
      keyPurpose: CamoKeyPurpose.messageEncryption,
      keyScope: CamoKeyScope.message,
      requestedAt: now,
      requiredEntitlements: const <CamoEntitlementType>{
        CamoEntitlementType.baseEncoding,
      },
      pairId: 'pair-001',
    ),
    createdAt: now,
    payloadReference: 'operation-001',
  );

  group('Fail-closed Enterprise Security Pipeline ports', () {
    test('security session port denies', () async {
      const port = FailClosedCamoSecuritySessionCoordinatorPort();

      expect(await port.validateSession(request), isFalse);
    });

    test('authorization gateway port denies', () async {
      const port = FailClosedCamoAuthorizationGatewayCoordinatorPort();

      expect(await port.validateFreshServerAuthorization(request), isFalse);
    });

    test('authorization port denies', () async {
      const port = FailClosedCamoAuthorizationCoordinatorPort();

      expect(await port.authorizeIdentityAndOperation(request), isFalse);
    });

    test('policy port denies', () async {
      const port = FailClosedCamoPolicyCoordinatorPort();

      expect(await port.evaluatePolicy(request), isFalse);
    });

    test('device trust port denies', () async {
      const port = FailClosedCamoDeviceTrustCoordinatorPort();

      expect(await port.validateDeviceTrust(request), isFalse);
    });

    test('risk port denies', () async {
      const port = FailClosedCamoRiskCoordinatorPort();

      expect(await port.evaluateRisk(request), isFalse);
    });

    test('licensing port denies', () async {
      const port = FailClosedCamoLicensingCoordinatorPort();

      expect(await port.validateCommercialAccess(request), isFalse);
    });

    test('KMS port returns no key reference', () async {
      const port = FailClosedCamoKmsCoordinatorPort();

      expect(await port.authorizeKeyRelease(request), isNull);
    });

    test('audit port safely records denial without authorizing', () async {
      const port = FailClosedCamoAuditCoordinatorPort();

      await port.recordAuthorizationDenied(
        request: request,
        failedStage: 'securitySession',
        reason: 'Denied by fail-closed test.',
      );
    });
  });
}
