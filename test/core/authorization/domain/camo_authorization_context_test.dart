// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_authorization_context.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoAuthorizationContext', () {
    test('stores immutable operation context', () {
      final Map<String, String> metadata = <String, String>{
        'policyVersion': '1',
      };
      final CamoAuthorizationContext context = CamoAuthorizationContext(
        operationId: 'operation-001',
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.encode,
        requestedAt: DateTime.utc(2026, 7, 11),
        pairId: 'pair-001',
        metadata: metadata,
      );
      metadata['policyVersion'] = '2';
      expect(context.operationId, 'operation-001');
      expect(context.hasPairContext, isTrue);
      expect(context.hasMessageContext, isFalse);
      expect(context.metadata['policyVersion'], '1');
    });
  });
}
