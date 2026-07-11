// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_enterprise_operation_execution_context.dart';
import '../entities/camo_enterprise_operation_outcome.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------
abstract interface class CamoAuthorizedOperationExecutor {
  Future<CamoResult<CamoEnterpriseOperationOutcome>> execute(
    CamoEnterpriseOperationExecutionContext context,
  );
}
