// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_context.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoKeyReleaseContext', () {
    test('message key requires message context', () {
      final CamoKeyReleaseContext context = CamoKeyReleaseContext(
        authorizationId: 'authorization-001',
        operationId: 'operation-001',
        userId: 'user-001',
        deviceId: 'device-001',
        operationType: CamoOperationType.decode,
        keyPurpose: CamoKeyPurpose.messageDecryption,
        keyScope: CamoKeyScope.message,
        requestedAt: DateTime.utc(2026, 7, 11),
        messageId: 'message-001',
      );
      expect(context.hasAuthorization, isTrue);
      expect(context.requiresMessageContext, isTrue);
      expect(context.hasMessageContext, isTrue);
    });
  });
}
