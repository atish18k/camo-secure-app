import '../../../operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import '../../../operation_coordinator/domain/entities/camo_enterprise_security_pipeline_result.dart';
import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_authorization_pipeline_decision.dart';
import '../../domain/services/camo_authorization_pipeline_decision_factory.dart';

final class FailClosedCamoAuthorizationPipelineDecisionFactory
    implements CamoAuthorizationPipelineDecisionFactory {
  const FailClosedCamoAuthorizationPipelineDecisionFactory();

  @override
  Future<CamoResult<CamoAuthorizationPipelineDecision>> create({
    required CamoEnterpriseOperationRequest request,
    required CamoEnterpriseSecurityPipelineResult pipelineResult,
  }) async {
    if (!request.isValid) {
      return const CamoError<CamoAuthorizationPipelineDecision>(
        CamoValidationFailure(
          code: 'enterprise_operation_request_invalid',
          message: 'Enterprise operation request is invalid.',
        ),
      );
    }

    if (!pipelineResult.isAuthorized) {
      return CamoError<CamoAuthorizationPipelineDecision>(
        CamoSecurityFailure(
          code: 'enterprise_security_pipeline_denied',
          message: pipelineResult.reason.trim().isEmpty
              ? 'Enterprise security pipeline denied the operation.'
              : pipelineResult.reason.trim(),
        ),
      );
    }

    return const CamoError<CamoAuthorizationPipelineDecision>(
      CamoSecurityFailure(
        code: 'authorization_decision_factory_not_production_ready',
        message:
            'A complete signed authorization decision cannot yet be created.',
      ),
    );
  }
}
