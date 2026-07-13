import '../../../operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import '../../../operation_coordinator/domain/entities/camo_enterprise_security_pipeline_result.dart';
import '../../../shared/result/camo_result.dart';
import '../entities/camo_authorization_pipeline_decision.dart';

abstract interface class CamoAuthorizationPipelineDecisionFactory {
  Future<CamoResult<CamoAuthorizationPipelineDecision>> create({
    required CamoEnterpriseOperationRequest request,
    required CamoEnterpriseSecurityPipelineResult pipelineResult,
  });
}
