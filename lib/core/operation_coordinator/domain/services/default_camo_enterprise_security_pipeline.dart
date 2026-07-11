// ignore_for_file: prefer_initializing_formals

import '../entities/camo_enterprise_operation_request.dart';
import '../entities/camo_enterprise_security_pipeline_result.dart';
import '../entities/camo_enterprise_security_pipeline_stage.dart';
import 'camo_enterprise_security_pipeline.dart';
import 'camo_enterprise_security_pipeline_ports.dart';

class DefaultCamoEnterpriseSecurityPipeline
    implements CamoEnterpriseSecurityPipeline {
  const DefaultCamoEnterpriseSecurityPipeline({
    required CamoSecuritySessionCoordinatorPort securitySessionPort,
    required CamoAuthorizationGatewayCoordinatorPort authorizationGatewayPort,
    required CamoAuthorizationCoordinatorPort authorizationPort,
    required CamoPolicyCoordinatorPort policyPort,
    required CamoDeviceTrustCoordinatorPort deviceTrustPort,
    required CamoRiskCoordinatorPort riskPort,
    required CamoLicensingCoordinatorPort licensingPort,
    required CamoKmsCoordinatorPort kmsPort,
    required CamoAuditCoordinatorPort auditPort,
    required DateTime Function() clock,
    required String Function() authorizationReferenceGenerator,
  }) : _securitySessionPort = securitySessionPort,
       _authorizationGatewayPort = authorizationGatewayPort,
       _authorizationPort = authorizationPort,
       _policyPort = policyPort,
       _deviceTrustPort = deviceTrustPort,
       _riskPort = riskPort,
       _licensingPort = licensingPort,
       _kmsPort = kmsPort,
       _auditPort = auditPort,
       _clock = clock,
       _authorizationReferenceGenerator = authorizationReferenceGenerator;

  final CamoSecuritySessionCoordinatorPort _securitySessionPort;
  final CamoAuthorizationGatewayCoordinatorPort _authorizationGatewayPort;
  final CamoAuthorizationCoordinatorPort _authorizationPort;
  final CamoPolicyCoordinatorPort _policyPort;
  final CamoDeviceTrustCoordinatorPort _deviceTrustPort;
  final CamoRiskCoordinatorPort _riskPort;
  final CamoLicensingCoordinatorPort _licensingPort;
  final CamoKmsCoordinatorPort _kmsPort;
  final CamoAuditCoordinatorPort _auditPort;
  final DateTime Function() _clock;
  final String Function() _authorizationReferenceGenerator;

  @override
  Future<CamoEnterpriseSecurityPipelineResult> authorize(
    CamoEnterpriseOperationRequest request,
  ) async {
    final bool sessionAllowed = await _securitySessionPort.validateSession(
      request,
    );

    if (!sessionAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.securitySession,
        reason: 'Security session validation failed.',
      );
    }

    final bool freshAuthorizationAllowed = await _authorizationGatewayPort
        .validateFreshServerAuthorization(request);

    if (!freshAuthorizationAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.authorizationGateway,
        reason: 'Fresh server authorization was denied.',
      );
    }

    final bool identityAuthorizationAllowed = await _authorizationPort
        .authorizeIdentityAndOperation(request);

    if (!identityAuthorizationAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.authorization,
        reason: 'Identity or operation authorization was denied.',
      );
    }

    final bool policyAllowed = await _policyPort.evaluatePolicy(request);

    if (!policyAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.policy,
        reason: 'Enterprise policy denied the operation.',
      );
    }

    final bool deviceAllowed = await _deviceTrustPort.validateDeviceTrust(
      request,
    );

    if (!deviceAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.deviceTrust,
        reason: 'Trusted device validation failed.',
      );
    }

    final bool riskAllowed = await _riskPort.evaluateRisk(request);

    if (!riskAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.risk,
        reason: 'Risk engine denied the operation.',
      );
    }

    final bool commercialAccessAllowed = await _licensingPort
        .validateCommercialAccess(request);

    if (!commercialAccessAllowed) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.licensing,
        reason: 'Subscription, license, or entitlement was denied.',
      );
    }

    final String? keyReference = await _kmsPort.authorizeKeyRelease(request);

    if (keyReference == null || keyReference.trim().isEmpty) {
      return _deny(
        request: request,
        stage: CamoEnterpriseSecurityPipelineStage.keyRelease,
        reason: 'KMS key release authorization failed.',
      );
    }

    final String authorizationReference = _authorizationReferenceGenerator();

    await _auditPort.recordAuthorizationGranted(
      request: request,
      authorizationReference: authorizationReference,
      keyReference: keyReference,
    );

    return CamoEnterpriseSecurityPipelineResult.authorized(
      decidedAt: _clock(),
      authorizationReference: authorizationReference,
      keyReference: keyReference,
    );
  }

  Future<CamoEnterpriseSecurityPipelineResult> _deny({
    required CamoEnterpriseOperationRequest request,
    required CamoEnterpriseSecurityPipelineStage stage,
    required String reason,
  }) async {
    await _auditPort.recordAuthorizationDenied(
      request: request,
      failedStage: stage.name,
      reason: reason,
    );

    return CamoEnterpriseSecurityPipelineResult.denied(
      stage: stage,
      reason: reason,
      decidedAt: _clock(),
    );
  }
}
