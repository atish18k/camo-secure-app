// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_enterprise_operation_outcome.dart';
import '../entities/camo_enterprise_operation_request.dart';
import '../services/camo_enterprise_operation_coordinator.dart';

// -----------------------------------------------------------------------------
// Use Case
// -----------------------------------------------------------------------------
final class CoordinateCamoEnterpriseOperationUseCase {
  const CoordinateCamoEnterpriseOperationUseCase(this._coordinator);
  final CamoEnterpriseOperationCoordinator _coordinator;
  Future<CamoResult<CamoEnterpriseOperationOutcome>> call(
    CamoEnterpriseOperationRequest request,
  ) {
    return _coordinator.coordinate(request);
  }
}
