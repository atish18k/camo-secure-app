import 'camo_enterprise_security_pipeline_stage.dart';

class CamoEnterpriseSecurityPipelineResult {
  const CamoEnterpriseSecurityPipelineResult._({
    required this.isAuthorized,
    required this.stage,
    required this.reason,
    required this.decidedAt,
    this.authorizationReference,
    this.keyReference,
  });

  factory CamoEnterpriseSecurityPipelineResult.authorized({
    required DateTime decidedAt,
    required String authorizationReference,
    required String keyReference,
  }) {
    return CamoEnterpriseSecurityPipelineResult._(
      isAuthorized: true,
      stage: CamoEnterpriseSecurityPipelineStage.completed,
      reason: 'Enterprise security pipeline authorized the operation.',
      decidedAt: decidedAt,
      authorizationReference: authorizationReference,
      keyReference: keyReference,
    );
  }

  factory CamoEnterpriseSecurityPipelineResult.denied({
    required CamoEnterpriseSecurityPipelineStage stage,
    required String reason,
    required DateTime decidedAt,
  }) {
    return CamoEnterpriseSecurityPipelineResult._(
      isAuthorized: false,
      stage: stage,
      reason: reason,
      decidedAt: decidedAt,
    );
  }

  final bool isAuthorized;
  final CamoEnterpriseSecurityPipelineStage stage;
  final String reason;
  final DateTime decidedAt;
  final String? authorizationReference;
  final String? keyReference;
}
