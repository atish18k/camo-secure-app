// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_authorization_decision.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_pipeline_decision.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_pipeline_status.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_session.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_status.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_token.dart';
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/authorization/domain/services/camo_enterprise_authorization_service.dart';
import 'package:camo/core/authorization/domain/usecases/authorize_camo_enterprise_operation_usecase.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_reference.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_decision.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/kms/domain/entities/camo_key_status.dart';
import 'package:camo/core/licensing/domain/entities/camo_commercial_access_decision.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_grant.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_decision.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_rule_result.dart';
import 'package:camo/core/policy_engine/domain/entities/camo_policy_rule_status.dart';
import 'package:camo/core/risk_engine/domain/entities/camo_risk_decision.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_risk_level.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Service
// -----------------------------------------------------------------------------
final class _FakeEnterpriseAuthorizationService
    implements CamoEnterpriseAuthorizationService {
  @override
  Future<CamoResult<CamoAuthorizationPipelineDecision>> authorize(
    CamoEnterpriseAuthorizationRequest request,
  ) async {
    final DateTime now = DateTime.now();
    final CamoAuthorizationDecision authorizationDecision =
        CamoAuthorizationDecision(
          authorizationId: 'authorization-001',
          status: CamoAuthorizationStatus.allowed,
          securityDecision: CamoSecurityDecision.allow,
          reasonCode: 'authorized',
          issuedAt: now,
          expiresAt: now.add(const Duration(seconds: 30)),
        );
    final CamoRiskDecision riskDecision = CamoRiskDecision(
      decisionId: 'risk-001',
      riskLevel: CamoRiskLevel.low,
      securityDecision: CamoSecurityDecision.allow,
      reasonCode: 'risk_acceptable',
      score: 10,
      evaluatedAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
    );
    final CamoCommercialAccessDecision commercialDecision =
        CamoCommercialAccessDecision(
          decisionId: 'commercial-001',
          securityDecision: CamoSecurityDecision.allow,
          reasonCode: 'commercial_access_allowed',
          evaluatedAt: now,
          expiresAt: now.add(const Duration(seconds: 30)),
          entitlementGrants: request.requiredEntitlements
              .map(
                (CamoEntitlementType entitlement) => CamoEntitlementGrant(
                  entitlementType: entitlement,
                  granted: true,
                  reasonCode: 'entitlement_active',
                ),
              )
              .toList(growable: false),
        );
    final CamoPolicyDecision policyDecision = CamoPolicyDecision(
      decisionId: 'policy-001',
      securityDecision: CamoSecurityDecision.allow,
      reasonCode: 'policy_allowed',
      policyVersion: '1',
      evaluatedAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
      ruleResults: const <CamoPolicyRuleResult>[
        CamoPolicyRuleResult(
          ruleId: 'all-required-checks',
          status: CamoPolicyRuleStatus.passed,
          reasonCode: 'all_checks_passed',
          message: 'All checks passed.',
        ),
      ],
    );
    final CamoKeyReleaseDecision keyReleaseDecision = CamoKeyReleaseDecision(
      releaseId: 'release-001',
      authorizationId: authorizationDecision.authorizationId,
      securityDecision: CamoSecurityDecision.allow,
      reasonCode: 'key_release_allowed',
      keyReference: CamoKeyReference(
        keyId: 'key-001',
        keyVersion: '1',
        provider: 'cloud-kms',
        purpose: request.keyPurpose,
        scope: request.keyScope,
        status: CamoKeyStatus.active,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 1)),
      ),
      issuedAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
      singleUse: true,
    );
    final CamoAuthorizationSession session = CamoAuthorizationSession(
      sessionId: 'session-001',
      token: CamoAuthorizationToken(
        tokenId: 'token-001',
        authorizationId: authorizationDecision.authorizationId,
        operationId: request.operationId,
        userId: request.userId,
        deviceId: request.deviceId,
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        singleUse: true,
        signature: 'signed-token',
      ),
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
      consumed: false,
    );
    return CamoSuccess<CamoAuthorizationPipelineDecision>(
      CamoAuthorizationPipelineDecision(
        pipelineId: 'pipeline-001',
        status: CamoAuthorizationPipelineStatus.completed,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'pipeline_authorized',
        authorizationDecision: authorizationDecision,
        riskDecision: riskDecision,
        commercialDecision: commercialDecision,
        policyDecision: policyDecision,
        keyReleaseDecision: keyReleaseDecision,
        session: session,
        completedAt: now,
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeSession(String sessionId) async {
    return const CamoSuccess<void>(null);
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test(
    'enterprise authorization use case returns permitted pipeline',
    () async {
      final AuthorizeCamoEnterpriseOperationUseCase useCase =
          AuthorizeCamoEnterpriseOperationUseCase(
            _FakeEnterpriseAuthorizationService(),
          );
      final CamoEnterpriseAuthorizationRequest request =
          CamoEnterpriseAuthorizationRequest(
            operationId: 'operation-001',
            userId: 'user-001',
            deviceId: 'device-001',
            operationType: CamoOperationType.encode,
            keyPurpose: CamoKeyPurpose.messageEncryption,
            keyScope: CamoKeyScope.message,
            requestedAt: DateTime.now(),
            messageId: 'message-001',
            requiredEntitlements: const <CamoEntitlementType>{
              CamoEntitlementType.baseEncoding,
            },
          );
      final CamoResult<CamoAuthorizationPipelineDecision> result =
          await useCase(request);
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.permitsOperation, isTrue);
    },
  );
}
