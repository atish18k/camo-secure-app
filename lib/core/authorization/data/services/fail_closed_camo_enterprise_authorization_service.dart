import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_authorization_pipeline_decision.dart';
import '../../domain/entities/camo_enterprise_authorization_request.dart';
import '../../domain/services/camo_enterprise_authorization_service.dart';

final class FailClosedCamoEnterpriseAuthorizationService
    implements CamoEnterpriseAuthorizationService {
  const FailClosedCamoEnterpriseAuthorizationService();

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

    return const CamoError<CamoAuthorizationPipelineDecision>(
      CamoSecurityFailure(
        code: 'enterprise_authorization_service_unavailable',
        message:
            'Production enterprise authorization service is not available.',
      ),
    );
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
        code: 'authorization_session_consumption_unavailable',
        message:
            'Production authorization session consumption is not available.',
      ),
    );
  }
}