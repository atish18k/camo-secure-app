import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_security_pipeline_stage.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_enterprise_security_pipeline_ports.dart';
import 'package:camo/core/operation_coordinator/domain/services/default_camo_enterprise_security_pipeline.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedTime = DateTime.utc(2026, 7, 11, 12);

  CamoEnterpriseOperationRequest createRequest() {
    return CamoEnterpriseOperationRequest(
      requestId: 'request-001',
      authorizationRequest: CamoEnterpriseAuthorizationRequest(
        operationId: 'operation-001',
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.encode,
        keyPurpose: CamoKeyPurpose.messageEncryption,
        keyScope: CamoKeyScope.message,
        requestedAt: fixedTime,
        requiredEntitlements: const <CamoEntitlementType>{
          CamoEntitlementType.baseEncoding,
        },
        messageId: 'message-001',
      ),
      createdAt: fixedTime,
    );
  }

  DefaultCamoEnterpriseSecurityPipeline createPipeline(
    _FakeSecurityPorts ports,
  ) {
    return DefaultCamoEnterpriseSecurityPipeline(
      securitySessionPort: ports,
      authorizationGatewayPort: ports,
      authorizationPort: ports,
      policyPort: ports,
      deviceTrustPort: ports,
      riskPort: ports,
      licensingPort: ports,
      kmsPort: ports,
      auditPort: ports,
      clock: () => fixedTime,
      authorizationReferenceGenerator: () => 'authorization-001',
    );
  }

  test('runs all enterprise security stages in strict order', () async {
    final List<String> calls = <String>[];
    final _FakeSecurityPorts ports = _FakeSecurityPorts(calls: calls);

    final result = await createPipeline(ports).authorize(createRequest());

    expect(result.isAuthorized, isTrue);
    expect(result.stage, CamoEnterpriseSecurityPipelineStage.completed);
    expect(result.authorizationReference, 'authorization-001');
    expect(result.keyReference, 'key-reference-001');

    expect(calls, <String>[
      'securitySession',
      'authorizationGateway',
      'authorization',
      'policy',
      'deviceTrust',
      'risk',
      'licensing',
      'kms',
      'auditGranted',
    ]);
  });

  test('fails fast when fresh server authorization is denied', () async {
    final List<String> calls = <String>[];

    final _FakeSecurityPorts ports = _FakeSecurityPorts(
      calls: calls,
      authorizationGatewayAllowed: false,
    );

    final result = await createPipeline(ports).authorize(createRequest());

    expect(result.isAuthorized, isFalse);
    expect(
      result.stage,
      CamoEnterpriseSecurityPipelineStage.authorizationGateway,
    );

    expect(calls, <String>[
      'securitySession',
      'authorizationGateway',
      'auditDenied',
    ]);

    expect(calls, isNot(contains('authorization')));
    expect(calls, isNot(contains('policy')));
    expect(calls, isNot(contains('kms')));
  });

  test('fails fast when trusted device validation is denied', () async {
    final List<String> calls = <String>[];

    final _FakeSecurityPorts ports = _FakeSecurityPorts(
      calls: calls,
      deviceTrustAllowed: false,
    );

    final result = await createPipeline(ports).authorize(createRequest());

    expect(result.isAuthorized, isFalse);
    expect(result.stage, CamoEnterpriseSecurityPipelineStage.deviceTrust);

    expect(calls.last, 'auditDenied');
    expect(calls, isNot(contains('risk')));
    expect(calls, isNot(contains('licensing')));
    expect(calls, isNot(contains('kms')));
  });

  test('denies operation when KMS does not release a key', () async {
    final List<String> calls = <String>[];

    final _FakeSecurityPorts ports = _FakeSecurityPorts(
      calls: calls,
      keyReference: null,
    );

    final result = await createPipeline(ports).authorize(createRequest());

    expect(result.isAuthorized, isFalse);
    expect(result.stage, CamoEnterpriseSecurityPipelineStage.keyRelease);
    expect(calls.last, 'auditDenied');
    expect(calls, isNot(contains('auditGranted')));
  });
}

class _FakeSecurityPorts
    implements
        CamoSecuritySessionCoordinatorPort,
        CamoAuthorizationGatewayCoordinatorPort,
        CamoAuthorizationCoordinatorPort,
        CamoPolicyCoordinatorPort,
        CamoDeviceTrustCoordinatorPort,
        CamoRiskCoordinatorPort,
        CamoLicensingCoordinatorPort,
        CamoKmsCoordinatorPort,
        CamoAuditCoordinatorPort {
  _FakeSecurityPorts({
    required this.calls,
    this.authorizationGatewayAllowed = true,
    this.deviceTrustAllowed = true,
    this.keyReference = 'key-reference-001',
  });

  final List<String> calls;
  final bool authorizationGatewayAllowed;
  final bool deviceTrustAllowed;
  final String? keyReference;

  @override
  Future<bool> validateSession(CamoEnterpriseOperationRequest request) async {
    calls.add('securitySession');
    return true;
  }

  @override
  Future<bool> validateFreshServerAuthorization(
    CamoEnterpriseOperationRequest request,
  ) async {
    calls.add('authorizationGateway');
    return authorizationGatewayAllowed;
  }

  @override
  Future<bool> authorizeIdentityAndOperation(
    CamoEnterpriseOperationRequest request,
  ) async {
    calls.add('authorization');
    return true;
  }

  @override
  Future<bool> evaluatePolicy(CamoEnterpriseOperationRequest request) async {
    calls.add('policy');
    return true;
  }

  @override
  Future<bool> validateDeviceTrust(
    CamoEnterpriseOperationRequest request,
  ) async {
    calls.add('deviceTrust');
    return deviceTrustAllowed;
  }

  @override
  Future<bool> evaluateRisk(CamoEnterpriseOperationRequest request) async {
    calls.add('risk');
    return true;
  }

  @override
  Future<bool> validateCommercialAccess(
    CamoEnterpriseOperationRequest request,
  ) async {
    calls.add('licensing');
    return true;
  }

  @override
  Future<String?> authorizeKeyRelease(
    CamoEnterpriseOperationRequest request,
  ) async {
    calls.add('kms');
    return keyReference;
  }

  @override
  Future<void> recordAuthorizationGranted({
    required CamoEnterpriseOperationRequest request,
    required String authorizationReference,
    required String keyReference,
  }) async {
    calls.add('auditGranted');
  }

  @override
  Future<void> recordAuthorizationDenied({
    required CamoEnterpriseOperationRequest request,
    required String failedStage,
    required String reason,
  }) async {
    calls.add('auditDenied');
  }
}
