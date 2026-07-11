// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_enterprise_operation_outcome.dart';
import '../entities/camo_enterprise_operation_request.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------
abstract interface class CamoEnterpriseOperationCoordinator {
  Future<CamoResult<CamoEnterpriseOperationOutcome>> coordinate(
    CamoEnterpriseOperationRequest request,
  );
}
