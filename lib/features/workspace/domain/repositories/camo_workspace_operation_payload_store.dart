import '../entities/camo_workspace_operation_payload.dart';

abstract interface class CamoWorkspaceOperationPayloadStore {
  void put(CamoWorkspaceOperationPayload payload);

  CamoWorkspaceOperationPayload? take(String operationId);

  void remove(String operationId);

  void clear();
}
