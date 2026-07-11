import '../../domain/entities/camo_workspace_operation_payload.dart';
import '../../domain/repositories/camo_workspace_operation_payload_store.dart';

final class CamoMemoryWorkspaceOperationPayloadStore
    implements CamoWorkspaceOperationPayloadStore {
  final Map<String, CamoWorkspaceOperationPayload> _payloads =
      <String, CamoWorkspaceOperationPayload>{};

  @override
  void put(CamoWorkspaceOperationPayload payload) {
    if (!payload.isValid) {
      throw ArgumentError.value(
        payload.operationId,
        'payload',
        'Workspace operation payload is invalid.',
      );
    }

    _payloads[payload.operationId] = payload;
  }

  @override
  CamoWorkspaceOperationPayload? take(String operationId) {
    final String normalizedOperationId = operationId.trim();

    if (normalizedOperationId.isEmpty) {
      return null;
    }

    return _payloads.remove(normalizedOperationId);
  }

  @override
  void remove(String operationId) {
    _payloads.remove(operationId.trim());
  }

  @override
  void clear() {
    _payloads.clear();
  }
}
