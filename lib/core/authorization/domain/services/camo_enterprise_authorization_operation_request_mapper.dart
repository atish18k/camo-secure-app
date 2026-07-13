import '../../domain/entities/camo_enterprise_authorization_request.dart';
import '../../../operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';

abstract interface class CamoEnterpriseAuthorizationOperationRequestMapper {
  CamoEnterpriseOperationRequest map(
    CamoEnterpriseAuthorizationRequest request,
  );
}
