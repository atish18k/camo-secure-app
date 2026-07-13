import 'package:camo/core/authorization/data/services/default_camo_enterprise_authorization_operation_request_mapper.dart';
import 'package:camo/core/authorization/data/services/fail_closed_camo_authorization_pipeline_decision_factory.dart';
import 'package:camo/core/authorization/data/services/pipeline_backed_camo_enterprise_authorization_service.dart';
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/operation_coordinator/data/services/fail_closed_camo_enterprise_security_pipeline_ports.dart';
import 'package:camo/core/operation_coordinator/domain/services/default_camo_enterprise_security_pipeline.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 7, 13);

  final service = PipelineBackedCamoEnterpriseAuthorizationService(
    pipeline: DefaultCamoEnterpriseSecurityPipeline(
      securitySessionPort: const FailClosedCamoSecuritySessionCoordinatorPort(),
      authorizationGatewayPort:
          const FailClosedCamoAuthorizationGatewayCoordinatorPort(),
      authorizationPort: const FailClosedCamoAuthorizationCoordinatorPort(),
      policyPort: const FailClosedCamoPolicyCoordinatorPort(),
      deviceTrustPort: const FailClosedCamoDeviceTrustCoordinatorPort(),
      riskPort: const FailClosedCamoRiskCoordinatorPort(),
      licensingPort: const FailClosedCamoLicensingCoordinatorPort(),
      kmsPort: const FailClosedCamoKmsCoordinatorPort(),
      auditPort: const FailClosedCamoAuditCoordinatorPort(),
      clock: () => now,
      authorizationReferenceGenerator: () => 'authorization-001',
    ),
    requestMapper: DefaultCamoEnterpriseAuthorizationOperationRequestMapper(
      requestIdGenerator: () => 'request-001',
      clock: () => now,
    ),
    decisionFactory: const FailClosedCamoAuthorizationPipelineDecisionFactory(),
  );

  test('fails closed when security pipeline denies', () async {
    final request = CamoEnterpriseAuthorizationRequest(
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
    );

    final result = await service.authorize(request);

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, 'enterprise_security_pipeline_denied');
  });

  test('rejects empty session consumption identifier', () async {
    final result = await service.consumeSession(' ');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, 'authorization_session_id_invalid');
  });

  test('valid session consumption remains fail closed', () async {
    final result = await service.consumeSession('session-001');

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'authorization_session_consumption_not_production_ready',
    );
  });
}
