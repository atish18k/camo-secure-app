import 'package:camo/core/authorization/data/services/fail_closed_camo_authorization_pipeline_decision_factory.dart';
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_security_pipeline_result.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_security_pipeline_stage.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 7, 13);

  final request = CamoEnterpriseOperationRequest(
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
    ),
    createdAt: now,
  );

  const factory = FailClosedCamoAuthorizationPipelineDecisionFactory();

  test('preserves pipeline denial', () async {
    final result = await factory.create(
      request: request,
      pipelineResult: CamoEnterpriseSecurityPipelineResult.denied(
        stage: CamoEnterpriseSecurityPipelineStage.authorizationGateway,
        reason: 'Fresh server authorization was denied.',
        decidedAt: now,
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, 'enterprise_security_pipeline_denied');
  });

  test('fails closed when pipeline reports authorization', () async {
    final result = await factory.create(
      request: request,
      pipelineResult: CamoEnterpriseSecurityPipelineResult.authorized(
        decidedAt: now,
        authorizationReference: 'authorization-001',
        keyReference: 'key-001',
      ),
    );

    expect(result.isFailure, isTrue);
    expect(
      result.failureOrNull?.code,
      'authorization_decision_factory_not_production_ready',
    );
  });
}
