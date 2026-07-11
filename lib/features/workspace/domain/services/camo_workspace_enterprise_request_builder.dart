import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';

abstract interface class CamoWorkspaceEnterpriseRequestBuilder {
  Future<CamoEnterpriseOperationRequest> buildEncodeRequest({
    required String operationId,
    required String pairingId,
    required bool camouflageEnabled,
  });

  Future<CamoEnterpriseOperationRequest> buildDecodeRequest({
    required String operationId,
    required String pairingId,
  });
}
