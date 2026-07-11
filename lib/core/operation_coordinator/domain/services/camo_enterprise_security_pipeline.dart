import '../entities/camo_enterprise_operation_request.dart';
import '../entities/camo_enterprise_security_pipeline_result.dart';

abstract interface class CamoEnterpriseSecurityPipeline {
  Future<CamoEnterpriseSecurityPipelineResult> authorize(
    CamoEnterpriseOperationRequest request,
  );
}
