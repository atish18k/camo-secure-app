import 'package:camo/features/workspace/data/services/fail_closed_camo_workspace_message_context_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailClosedCamoWorkspaceMessageContextResolver', () {
    const FailClosedCamoWorkspaceMessageContextResolver resolver =
        FailClosedCamoWorkspaceMessageContextResolver();

    test('rejects missing pairing identifier', () async {
      expect(
        () => resolver.resolveMessageId(
          pairingId: ' ',
          operationId: 'operation-001',
        ),
        throwsStateError,
      );
    });

    test('fails closed when identifiers are valid', () async {
      expect(
        () => resolver.resolveMessageId(
          pairingId: 'pairing-001',
          operationId: 'operation-001',
        ),
        throwsStateError,
      );
    });
  });
}