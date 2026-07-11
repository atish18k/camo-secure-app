import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/features/workspace/data/repositories/camo_memory_workspace_operation_payload_store.dart';
import 'package:camo/features/workspace/domain/entities/camo_workspace_operation_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores and consumes an encode payload exactly once', () {
    final CamoMemoryWorkspaceOperationPayloadStore store =
        CamoMemoryWorkspaceOperationPayloadStore();

    const CamoWorkspaceOperationPayload payload = CamoWorkspaceOperationPayload(
      operationId: 'operation-001',
      pairingId: 'pairing-001',
      operationType: CamoOperationType.encode,
      plainText: 'secret',
    );

    store.put(payload);

    expect(store.take('operation-001'), same(payload));
    expect(store.take('operation-001'), isNull);
  });

  test('stores and clears a decode payload', () {
    final CamoMemoryWorkspaceOperationPayloadStore store =
        CamoMemoryWorkspaceOperationPayloadStore();

    const CamoWorkspaceOperationPayload payload = CamoWorkspaceOperationPayload(
      operationId: 'operation-002',
      pairingId: 'pairing-001',
      operationType: CamoOperationType.decode,
      encodedText: 'encoded',
    );

    store.put(payload);
    store.clear();

    expect(store.take('operation-002'), isNull);
  });

  test('rejects invalid local operation payload', () {
    final CamoMemoryWorkspaceOperationPayloadStore store =
        CamoMemoryWorkspaceOperationPayloadStore();

    expect(
      () => store.put(
        const CamoWorkspaceOperationPayload(
          operationId: 'operation-003',
          pairingId: 'pairing-001',
          operationType: CamoOperationType.encode,
        ),
      ),
      throwsArgumentError,
    );
  });
}
