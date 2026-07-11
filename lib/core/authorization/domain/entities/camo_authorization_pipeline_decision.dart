// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../kms/domain/entities/camo_key_release_decision.dart';
import '../../../licensing/domain/entities/camo_commercial_access_decision.dart';
import '../../../policy_engine/domain/entities/camo_policy_decision.dart';
import '../../../risk_engine/domain/entities/camo_risk_decision.dart';
import '../../../shared/types/camo_security_decision.dart';
import 'camo_authorization_decision.dart';
import 'camo_authorization_pipeline_status.dart';
import 'camo_authorization_session.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationPipelineDecision {
  const CamoAuthorizationPipelineDecision({
    required this.pipelineId,
    required this.status,
    required this.securityDecision,
    required this.reasonCode,
    required this.authorizationDecision,
    required this.riskDecision,
    required this.commercialDecision,
    required this.policyDecision,
    required this.keyReleaseDecision,
    required this.session,
    required this.completedAt,
  });
  final String pipelineId;
  final CamoAuthorizationPipelineStatus status;
  final CamoSecurityDecision securityDecision;
  final String reasonCode;
  final CamoAuthorizationDecision authorizationDecision;
  final CamoRiskDecision riskDecision;
  final CamoCommercialAccessDecision commercialDecision;
  final CamoPolicyDecision policyDecision;
  final CamoKeyReleaseDecision keyReleaseDecision;
  final CamoAuthorizationSession session;
  final DateTime completedAt;
  bool get permitsOperation {
    return status.isSuccessful &&
        securityDecision.isAllowed &&
        authorizationDecision.permitsOperation &&
        riskDecision.permitsOperation &&
        commercialDecision.permitsOperation &&
        policyDecision.permitsOperation &&
        keyReleaseDecision.permitsKeyRelease &&
        session.isActive;
  }
}
