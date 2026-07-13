import '../../../operation_coordinator/domain/services/camo_enterprise_security_pipeline.dart';
import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_authorization_pipeline_decision.dart';
import '../../domain/entities/camo_enterprise_authorization_request.dart';
import '../../domain/services/camo_authorization_pipeline_decision_factory.dart';
import '../../domain/services/camo_enterprise_authorization_operation_request_mapper.dart';
import '../../domain/services/camo_enterprise_authorization_service.dart';

final class PipelineBackedCamoEnterpriseAuthorizationService
    implements CamoEnterpriseAuthorizationService {
  const PipelineBackedCamoEnterpriseAuthorizationService({
    required this.pipeline,
    required this.requestMapper,
    required this.decisionFactory,
  });

  final CamoEnterpriseSecurityPipeline pipeline;
  final CamoEnterpriseAuthorizationOperationRequestMapper requestMapper;
  final CamoAuthorizationPipelineDecisionFactory decisionFactory;

  @override
  Future<CamoResult<CamoAuthorizationPipelineDecision>> authorize(
    CamoEnterpriseAuthorizationRequest request,
  ) async {
    if (!request.isValid) {
      return const CamoError<CamoAuthorizationPipelineDecision>(
        CamoValidationFailure(
          code: 'enterprise_authorization_request_invalid',
          message: 'Enterprise authorization request is invalid.',
        ),
      );
    }

    try {
      final operationRequest = requestMapper.map(request);
      final pipelineResult = await pipeline.authorize(operationRequest);

      return decisionFactory.create(
        request: operationRequest,
        pipelineResult: pipelineResult,
      );
    } on Object catch (error) {
      return CamoError<CamoAuthorizationPipelineDecision>(
        CamoUnexpectedFailure(
          code: 'pipeline_backed_authorization_service_failure',
          message:
              'Pipeline-backed Enterprise Authorization Service failed closed.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<CamoResult<void>> consumeSession(String sessionId) async {
    if (sessionId.trim().isEmpty) {
      return const CamoError<void>(
        CamoValidationFailure(
          code: 'authorization_session_id_invalid',
          message: 'Authorization session identifier is required.',
        ),
      );
    }

    return const CamoError<void>(
      CamoSecurityFailure(
        code: 'authorization_session_consumption_not_production_ready',
        message:
            'Production authorization-session consumption is not available.',
      ),
    );
  }
}
